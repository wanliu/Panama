#encoding: utf-8
#describe: 订单交易
#attributes:
#  operator_state: 订单处理状态(true: 有人处理, false: 没有人处理)
#  operator_id: 当前操作员
#  buyer_id: 买家(用户)
#  seller_id: 卖家(商店)
#  state: 交易状态
#  total: 总金额
#  address: 送货地址
#  items_count: 商品总项
#  delivery_code: 快递单号
#  pay_manner: 付款方式
#  delivery_manner: 配送方式
#  transfer_sheet: 汇款单
class OrderTransaction < ActiveRecord::Base
  include MessageQueue::Transaction

  scope :completed, -> { where("state in (?)", [:complete, :close, :refund]) }
  scope :uncomplete, -> { where("state not in (?)", [:complete, :close, :refund]) }
  scope :buyer, ->(person){ where(:buyer_id => person.id) }
  scope :seller, ->(seller){ where(:seller_id => seller.id) }

  attr_accessible :buyer_id, :items_count, :seller_id, :state, :total, :address, :delivery_price, :pay_type, :transport_type

  belongs_to :address,
          foreign_key: 'address_id', class_name: "DeliveryAddress"

  belongs_to :seller, class_name: "Shop"
  belongs_to :buyer, class_name: "User"
  belongs_to :operator, class_name: "TransactionOperator"

  has_many :notifications, :as => :targeable, dependent: :destroy
  has_many :operators, class_name: "TransactionOperator", :dependent => :destroy
  has_many :transfer_moneys, :as => :owner
  has_many :transfers, :as => :targeable, autosave: true

  has_many  :items,
            class_name: "ProductItem",
            as: :owner,
            autosave: true,
            dependent: :destroy

  has_many :state_details, class_name: "TransactionStateDetail", dependent: :destroy
  has_many :refunds, class_name: "OrderRefund", dependent: :destroy
  has_one  :transfer_sheet, class_name: "TransferSheet", dependent: :destroy, inverse_of: :order_transaction
  has_one :temporary_channel, as: :targeable, dependent: :destroy
  has_one :answer_ask_buy

  validates :state, :presence => true

  validates_presence_of :buyer
  validates_presence_of :seller
  validates_numericality_of :items_count
  validates_numericality_of :total, :greater_than_or_equal_to => 1
  validates :number, :presence => true, :uniqueness => true
  validate :valid_base_info?
  validate :shop_checked?

  #在线支付类型 account: 帐户支付 kuaiqian: 快钱支付
  acts_as_status :pay_status, [:account, :kuaiqian, :bank_transfer]

  before_validation(:on => :create) do
    update_total_count
    generate_number        
    generate_transfer
  end

  after_create do    
    state_change_detail
    notice_user    
  end

  after_save do     
    notify_seller_change
  end

  before_destroy do 
    update_transfer_failer
  end

  after_commit :create_the_temporary_channel, on: :create

  def notice_user
    Notification.dual_notify(seller,
      :channel => "/#{seller.im_token}/transactions/create",
      :content => "你有编号#{number}新的订单",
      :url => seller_open_path,
      :order_id => id,
      :target => self
    ) do |options|
      options[:channel] = "/transactions/create"
    end
  end
  after_destroy :notice_destroy, :destroy_activity

  state_machine :initial => :order do

    #在线确认订单 到 等待
    event :online_payment do
      transition :order => :waiting_paid
    end

    #银行汇款方式
    event :bank_transfer do
      transition :order => :waiting_transfer
    end

    #转帐
    event :transfer do
      transition :waiting_transfer => :waiting_audit
    end

    #审核转帐通过
    event :audit_transfer do
      transition :waiting_audit => :waiting_delivery
    end

    #审核未通过
    event :audit_failure do
      transition :waiting_audit => :waiting_audit_failure
    end

    #确认转帐信息
    event :confirm_transfer do
      transition :waiting_audit_failure => :waiting_audit
    end

    #过期事件
    event :expired do
      transition  :order             =>  :close,
                  :waiting_transfer  =>  :close,
                  :waiting_audit_failure =>  :close,
                  :waiting_paid      =>  :close,
                  :refund            =>  :close,
                  :complete          =>  :close,
                  :waiting_delivery  =>  :delivery_failure,
                  :waiting_sign      =>  :complete

    end

    #退货事件方式
    event :returned do
      #发货失败`等待发货`签收 到 退货
      transition :waiting_refund => :refund,
                 [:delivery_failure, :waiting_delivery, :waiting_sign, :complete] => :waiting_refund

    end

    event :rollback_delivery_failure do
      transition :waiting_refund => :delivery_failure
    end

    event :rollback_waiting_delivery do
      transition :waiting_refund => :waiting_delivery
    end

    event :rollback_waiting_sign do
      transition :waiting_refund => :waiting_sign
    end

    event :rollback_complete do
      transition :waiting_refund => :complete
    end

    #付款
    event :paid do
      # 等待付款 到 等待发货
      transition :waiting_paid => :waiting_delivery
    end

    #发货
    event :delivered do
      # 等待发货 到 等待签收
      transition :waiting_delivery => :waiting_sign
    end

    #签收
    event :sign do
      # 等待签收 到 完成
      transition :waiting_sign => :complete
    end

    state :waiting_sign do
      # 提前申请延长收货的时限
      def pre_delay_sign_time
        3.days
      end
      # 申请延长收货增加的时间
      def delay_sign_time
        3.days
      end
    end

    after_transition :waiting_paid => :waiting_delivery do |order, transition|
      order.buyer_payment      
      order.activity_tran.participate if order.activity_tran.present?      
    end

    after_transition do |order, transaction|
      if transaction.event == :back
        if order.state == order.state_details.last.state
          order.state_details.last.destroy
        end
      else
        order.state_change_detail
      end
    end

    #商家发货延时
    after_transition :waiting_delivery => :delivery_failure do |order, transition|
      order.expired_delivery
    end

    after_transition [:order, :waiting_paid, :waiting_transfer, :waiting_audit_failure] => :close do |order, transition|
      order.update_transfer_failer
    end

    after_transition [:waiting_paid, :waiting_audit] => :waiting_delivery do |order, transition|
      order.update_transfer_success
      order.create_item_sales
    end

    after_transition :waiting_sign => :complete do |order, transition|
      order.seller_recharge
    end

    after_transition :waiting_audit => :waiting_delivery do |order, transition|
      order.buyer_payment
    end

    after_transition :waiting_transfer => :waiting_audit do |order, transition|
      order.update_pay_status(:bank_transfer)
    end

    before_transition :waiting_delivery => :waiting_sign do |order, transition|
    end

    before_transition :waiting_paid => :waiting_delivery  do |order, transition|
      if order.pay_status == :invalid && order.valid_payment?
        order.update_pay_status(:account)
      end
    end

    before_transition :order => [:waiting_paid, :waiting_transfer] do |order, transition|
      order.update_transport
    end

    before_transition :waiting_transfer => :waiting_audit do |order, transition|
      order.valid_transfer_sheet?
    end
  end

  def notice_destroy
    target = current_operator.nil? ? seller : current_operator
    Notification.dual_notify(target,
      :channel => "/#{seller.im_token}/transactions/destroy",
      :content => "订单#{number}被删除！",
      :url => "/shops/#{seller.name}/admins/pendding",
      :order_id => id
    ) do |options|
      options[:channel] = "/transactions/destroy"
    end
  end

  #如果卖家没有发货直接删除明细，返还买家的金额
  def refund_handle_detail_return_money(refund)
    product_ids = refund.refund_product_ids
    refund_items = get_refund_items(product_ids)
    if not_product_refund(product_ids).present?
      refund_items.destroy_all
      update_total_count
    end
    refund.buyer_recharge if save
  end

  def generate_number
    _number = (OrderTransaction.max_id + 1).to_s
    self.number = if _number.length < 9
      "#{'0' * (9-_number.length)}#{_number}"
    else
      _number
    end
  end

  def generate_transfer
    items.each do |item|
      transfers.build(
        :amount => -item.amount,        
        :shop_product => item.shop_product)      
    end
  end

  def transport_type_name
    transport_type || "暂无"
  end

  def get_refund_items(product_ids)
    items.where(:product_id => product_ids)
  end

  #订单商品全退货了
  def not_product_refund(product_ids)
    items.where("product_id not in (?)", product_ids).first
  end

  def shipped_state?
    %w(waiting_sign complete).include?(state)
  end

  def order_state?
    "order" == state
  end

  def waiting_sign_state?
    "waiting_sign" == state
  end

  def waiting_audit_state?
    "waiting_audit" == state
  end

  def unshipped_state?
    %w(delivery_failure waiting_delivery).include?(state)
  end

  #是否成功
  def complete_state?
    state == "complete"
  end

  def refund_state?
    state == "refund"
  end

  def wating_refund_state?
    state == "waiting_refund"
  end

  def order_refund_state?
    %w(delivery_failure
      waiting_delivery
      waiting_sign
      complete).include?(state)
  end

  def close_state?
    %w(close order waiting_paid).include?(state)
  end

  def buyer_fire_event!(event)
    events = %w(online_payment bank_transfer back paid sign transfer confirm_transfer)
    if filter_fire_event!(events, event)
      change_state_notify_seller(event)
    end
  end

  def system_fire_event!(event)
    events = %w(expired audit_transfer audit_failure)
    if filter_fire_event!(events, event)
      change_state_notify_seller(event)
      change_state_notify_buyer(event)    
    end
  end

  def seller_fire_event!(event)
    events = %w(back delivered)
    if filter_fire_event!(events, event)
      change_state_notify_buyer(event)
    end
  end

  def change_state_notify_seller(event = nil)
    target = current_operator.nil? ? seller : current_operator    
    Notification.dual_notify(target,
      :channel => "/#{seller.im_token}/transactions/#{id}/change_state",
      :content => "您的订单#{number}买家已经#{seller_state_title}",
      :order_id => id,
      :state => state_name,
      :event => "refresh_#{event}",
      :state_title => seller_state_title,
      :url => seller_open_path
    ) do |options|
      options[:channel] = "/transactions/change_state"
    end
  end

  def change_state_notify_buyer(event = nil)    
    Notification.dual_notify(buyer,
      :channel => "/transactions/#{id}/change_state",
      :content => "您的订单#{number}卖家已经#{buyer_state_title}",
      :order_id => id,
      :state => state_name,
      :state_title => buyer_state_title,
      :event => "refresh_#{event}",
      :url => buyer_open_path
    ) do |options|
      options[:channel] = "/transactions/change_state"
    end
  end

  def way_change_state_notify_buyer(event = nil)
    buyer.notify(
      "/transactions/#{id}/change_state",
      "您的订单#{number}卖家已经#{buyer_state_title}",
      :order_id => id,
      :state => state_name,
      :state_title => buyer_state_title,
      :event => "refresh_#{event}",
      :persistent => false,
      :url => buyer_open_path
    )
  end

  def refund_items
    OrderRefundItem.where(
      :order_refund_id => refunds.pluck("id"))
  end

  def kuaiqian_paid
    update_pay_status(:kuaiqian)    
    buyer_fire_event!(:paid)
  end

  #付款
  def buyer_payment
    buyer.payment(stotal,{
      :owner => self,
      :pay_type => pay_status.name,
      :target => seller.user,
      :decription => "订单#{number}付款",
      :state => false })      
  end

  #卖家收款
  def seller_recharge    
    transfer_moneys.find_by( 
      :user_id => seller.user.id,     
      :source_type => "User",
      :source_id => buyer.id).active_money
  end

  def update_pay_status(status)
    self.update_attribute(:pay_status, status)
  end

  def update_transfer_success
    transfers.each{|t| t.update_success }
  end

  def update_transfer_failer
    transfers.each{|t| t.update_failer }
  end

  def create_item_sales
    items.each{|i| i.create_sales_item }
  end

  def get_delivery_price
    transport = OrderTransportType.get(transport_type)
    transport.blank? ? 0 : (transport.price || 0)
  end

  def pay_type_name
    OrderPayType.get(pay_type).name
  end

  def activity_tran
    ActivitiesOrderTransaction.find_by(
      :order_transaction_id => id)
  end

  #变更状态
  def state_change_detail
    state_details.update_all(:expired_state => false)
    state_details.create(:state => state)
  end

  def current_operator
    operator.try(:operator)
  end

  def current_state_detail
    state_details.find_by(:state => state)
  end

  def operator_create(user_id)
    _operator = operators.create(operator_id: user_id)
    notice_change_operator(_operator.operator) if _operator.valid?
    _operator
  end

  def notice_change_operator(user)    
    Notification.dual_notify(seller,
      :channel => "/#{seller.im_token}/transactions/dispose",
      :content => "#{user.login}处理 #{number}订单",
      :order_id => id,
      :url => buyer_open_path,
      :exclude => user
    ) do |options|
      options[:channel] = "/transactions/dispose"
    end

    buyer.notify(
      "/transactions/dispose",
      "#{user.login}处理 #{number}订单",
      :order_id => id,
      :persistent => false      
    )
  end

  def build_items(item_ar)
    item_ar.each { |item| items.build(item) }
    self
  end

  def update_total_count
    self.items_count = items.inject(0) { |s, item| s + (item.amount || 0) }
    self.total = items.inject(0) { |s, item| s + item.total }
  end

  def stotal
    (total || 0) + (delivery_price || 0)
  end

  def as_json(*args)
    attra = super *args
    attra["number"] = number
    attra["buyer_login"] = buyer.try(:login)
    attra["seller_name"] = seller.name
    attra["address"] = address.try(:address_only)
    attra["stotal"] = stotal
    attra["created_at"] = created_at.strftime("%Y-%m-%d %H:%M:%S")
    attra
  end

  def seller_state_title
    state_title("seller")
  end

  def buyer_state_title
    state_title("buyer")
  end

  def valid_transfer_sheet?
    errors.add(:transfer_sheet, "没有汇款单号!") if transfer_sheet.nil?
  end

  def valid_payment?
    if buyer.valid_money?(stotal)
      errors.add(:buyer, "您的金额不足!")
      false
    else
      true
    end
  end

  def create_transfer(options = {})
    if transfer_sheet.nil?
      TransferSheet.create(
        options.merge(:order_transaction => self))
    else
      transfer_sheet.update_attributes(options)
      transfer_sheet
    end
  end

  def update_transport
    if OrderTransportType.exists?(transport_type)
      self.delivery_price = get_delivery_price
    end
  end

  def can_delay_sign_expired?
    waiting_sign_state? && DateTime.now > current_state_detail.expired - pre_delay_sign_time
  end

  def self.max_id
    select("max(id) as id")[0].try(:id) || 0
  end

  def self.state_expired
    transactions = find(:all,
      :joins => "left join transaction_state_details as details
      on details.order_transaction_id = order_transactions.id and
      details.state = order_transactions.state and details.expired_state=true",
      :conditions => ["details.expired <=?", DateTime.now],
      :readonly => false)
    transactions.each{|t| t.fire_events!(:expired) }
    puts "=order===start: #{DateTime.now}=====count: #{transactions.count}===="
    transactions
  end

  def self.export_column
    {
      "number" => "编号",
      "state_title" => "状态",
      "pay_type" => "支付方式",
      "transport_type" => "运输方式",
      "buyer_login" => "买家",
      "seller_name" => "商家",
      "title" => "商品",
      "price" => "单价",
      "amount" => "数量",
      "delivery_price" => "运费",
      "stotal" => "总额",
      "address" => "地址"
    }
  end

  def convert_json
    items.map do |item|
      attra = item.as_json
      attra.merge!(as_json)
      attra
    end
  end

  def notify_buyer_change
    Notification.dual_notify(buyer, 
      :channel => "/transactions/#{id}/change_info",
      :content => "订单#{number}已经修改运费",
      :url => buyer_open_path,
      :info => {
        :stotal => stotal,
        :delivery_price => delivery_price
      },        
      :order_id => id
    ) do |options|
      options[:channel] = "/transactions/change_info"
    end
  end

  private

  def shop_checked?
    shop = Shop.find(seller_id)
    unless shop.actived
      errors.add(:shop, "商店还未通过审核，暂时还不能购买") 
    end
  end

  def valid_base_info?
    unless %w(order close).include?(state)
      if pay_type.blank? || !OrderPayType.exists?(pay_type)
        errors.add(:pay_type, "请选择支付方式!")
      end
      errors.add(:address, "地址不存在！") if address.nil?
    end

    if changed.include?("delivery_price")      
      unless edit_delivery_price_valid? || 
        transport_type.blank? || state_name == :order
        errors.add(:delivery_price, "这个状态不能修改运费！")
      end
    end

    if %w(waiting_paid waiting_delivery).include?(state) && activity_tran.present?
      unless activity_tran.activity.valid_expired?
        errors.add(:state, "活动过期不能付款了?")
      end
    end
  end  

  def notify_seller_change
    return unless persisted?  
    attas = ["delivery_price", "address_id"]
    if changed.map{|c| attas.include?(c) }.any?
      target = current_operator.nil? ? seller : current_operator
      options = {
        :order_id => id,
        :persistent => false,
        :url => seller_open_path,
        :info => {
          :stotal => stotal,
          :address => address.try(:location)  
        }
      }
      
      target.notify(
        "/#{seller.im_token}/transactions/#{id}/change_info",
        "订单#{number}资料修改!",
        options)
    end
  end

  def filter_fire_event!(events = [], event)
    name = event.to_s
    if events.include?(name)
      fire_events!(name)
    else
      false
    end
  end

  def destroy_activity
    activity_tran.destroy if activity_tran.present?
  end

  def state_title(owner)
    I18n.t("order_states.#{owner}.#{state}")
  end

  def create_the_temporary_channel
    name = self.class.to_s << "_" << number
    self.create_temporary_channel(targeable_type: "OrderTransaction", user_id: seller.owner.id, name: name)
  end

  def edit_delivery_price_valid?
    name = OrderPayType.get(pay_type)["name"]
    if name == "online_payment"
      state_name == :waiting_paid
    elsif name == "bank_transfer"
      state_name == :waiting_transfer
    elsif name.blank?
      state_name == :order
    else
      false
    end
  end

  def buyer_open_path
    "/people/#{buyer.login}/transactions#open/#{id}/order"
  end

  def seller_open_path
    "/shops/#{seller.name}/admins/pending#open/#{id}/order"
  end

end
