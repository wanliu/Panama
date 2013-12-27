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

  attr_accessible :buyer_id, :items_count, :seller_id, :state, :total, :address, :delivery_type_id, :delivery_price, :pay_manner, :delivery_manner

  belongs_to :address,
          foreign_key: 'address_id', class_name: "DeliveryAddress"
  belongs_to :delivery_type,
          foreign_key: "delivery_type_id"

  belongs_to :seller, class_name: "Shop"
  belongs_to :buyer, class_name: "User"
  belongs_to :operator, class_name: "TransactionOperator"
  belongs_to :pay_manner
  belongs_to :delivery_manner
  belongs_to :logistics_company

  has_many :notifications, :as => :targeable, dependent: :destroy
  has_many :operators, class_name: "TransactionOperator", :dependent => :destroy

  has_many  :items,
            class_name: "ProductItem",
            as: :owner,
            autosave: true,
            dependent: :destroy

  has_many :chat_messages, :as => :owner, dependent: :destroy
  has_many :state_details, class_name: "TransactionStateDetail", dependent: :destroy
  has_many :refunds, class_name: "OrderRefund", dependent: :destroy
  has_one  :transfer_sheet, class_name: "TransferSheet", dependent: :destroy, inverse_of: :order_transaction
  has_one :temporary_channel, as: :targeable, dependent: :destroy

  validates :state, :presence => true

  validates_presence_of :buyer
  validates_presence_of :seller
  validates_associated :address
  validates_numericality_of :items_count
  validates_numericality_of :total
  validates :number, :presence => true, :uniqueness => true
  validate :valid_base_info?

  accepts_nested_attributes_for :address

  #在线支付类型 account: 帐户支付 kuaiqian: 快钱支付
  acts_as_status :online_pay_type, [:account, :kuaiqian]

  before_validation(:on => :create) do
    update_total_count
    generate_number
  end

  after_create do
    state_change_detail
    notice_user
  end

  after_commit :create_the_temporary_channel, on: :create

  def notice_user
    seller.notify("/#{seller.im_token}/transactions/create", "你有编号#{number}新的订单",
      :url => "/shops/#{seller.name}/admins/transactions/#{id}",
      :order_id => id,
      :target => self)
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

    #货到付款方式
    event :cash_on_delivery do
      transition :order => :waiting_delivery
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

    event :back do
      transition :waiting_paid     => :order,
                 :waiting_delivery => :waiting_paid,
                 :waiting_sign     => :waiting_delivery
    end

    #过期事件
    event :expired do
      transition  :order             =>  :close,
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

    ## only for development
    # if Rails.env.development?
    #   after_transition :waiting_paid      => :order,
    #                    :waiting_delivery  => :waiting_paid,
    #                    :waiting_sign      => :waiting_delivery do |order, transition|
    #     order.notice_change_seller(transition.to_name, :back)
    #   end
    # end

    after_transition :waiting_paid => :waiting_delivery do |order, transition|
      if order.online_pay_type == :account
        order.buyer_payment
        order.activity.participate if order.activity.present?
      end
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

    after_transition :waiting_sign => :complete do |order, transition|
      order.seller_recharge
    end

    before_transition :waiting_delivery => :waiting_sign do |order, transition|
      order.valid_delivery?
      order.valid_delivery_manner?
    end

    before_transition :waiting_paid => :waiting_delivery  do |order, transition|
      unless order.online_pay_type == :kuaiqian
        if order.valid_payment?
          order.update_attribute(:online_pay_type, :account)
        end
      end
    end

    before_transition :order => [:waiting_paid, :waiting_transfer, :waiting_delivery] do |order, transition|
      order.valid_pay_manner?
      order.update_delivery
    end

    before_transition :waiting_transfer => :waiting_audit do |order, transition|
      order.valid_transfer_sheet?
    end
  end

  def notice_destroy
    target = current_operator.nil? ? seller : current_operator
    target.notify(
      "/#{seller.im_token}/transactions/destroy",
      "订单#{number}被删除！",
      :order_id => id,
      :url => "/shops/#{seller.name}/admins/pendding")
  end

  #如果卖家没有发货直接删除明细，返还买家的金额
  def refund_handle_detail_return_money(refund)
    product_ids = refund.refund_product_ids
    refund_items = get_refund_items(product_ids)
    if not_product_refund(product_ids).present?
      refund_items.destroy_all
      update_total_count
    end
    if !pay_manner.cash_on_delivery? && save
      refund.buyer_recharge
    end
  end

  def generate_number
    _number = (OrderTransaction.max_id + 1).to_s
    self.number = if _number.length < 9
      "#{'0' * (9-_number.length)}#{_number}"
    else
      _number
    end
  end

  def delivery_express?
    delivery_manner && delivery_manner.express?
  end

  def delivery_local?
    delivery_manner && delivery_manner.local_delivery?
  end

  def delivery_name
    delivery_manner.nil? ? '卖家选择' : delivery_manner.name
  end

  def delivery_type_name
    delivery_type.nil? ? "暂无" : delivery_type.name
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

  def undelayed_sign_state?
    %w(waiting_sign).include?(state)
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

  def edit_delivery_price?
    if pay_manner.online_payment?
      state_name == :waiting_paid
    elsif pay_manner.bank_transfer?
      state_name == :waiting_transfer
    elsif pay_manner.cash_on_delivery?
      state_name == :waiting_delivery
    else
      false
    end
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
    events = %w(online_payment cash_on_delivery bank_transfer back paid sign transfer confirm_transfer)
    event = pay_manner.code if event.to_s == "buy"
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
    target.notify(
      "/#{seller.im_token}/transactions/#{id}/change_state",
      "您的订单#{number}买家已经#{seller_state_title}",
      :order_id => id,
      :state => state_name,
      :event => "refresh_#{event}",
      :state_title => seller_state_title,
      :url => "/shops/#{seller.name}/admins/transactions/#{id}"
    )
  end

  def change_state_notify_buyer(event = nil)
    buyer.notify(
      "/transactions/#{id}/change_state",
      "您的订单#{number}卖家已经#{buyer_state_title}",
      :order_id => id,
      :state => state_name,
      :state_title => buyer_state_title,
      :event => "refresh_#{event}",
      :url => "/people/#{buyer.login}/transactions/#{id}"
    )
  end

  def refund_items
    OrderRefundItem.where(
      :order_refund_id => refunds.map{|item| item.id})
  end

  def online_paid
    self.update_attribute(:online_pay_type, :kuaiqian)
    self.buyer_fire_event!(:paid)
  end

  #付款
  def buyer_payment
    buyer.payment(stotal, self, "订单付款给#{seller.name}")
  end

  #卖家收款
  def seller_recharge
    unless pay_manner.cash_on_delivery?
      seller.user.recharge(stotal, self, "#{buyer.login}购买商品款")
    end
  end

  def get_delivery_price(delivery_id)
    delivery_type.try(:price) || 0
  end

  def activity
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
    seller.notify(
      "/#{seller.im_token}/transactions/dispose",
      "#{user.login}处理 #{number}订单",
      :persistent => false,
      :order_id => id,
      :exclude => user
    )
  end

  #买家发送信息
  def message_create(options)
    #是否有销售组成员在线
    unless seller.seller_group_employees.any?{|u| u.connect_state }
      not_service_online(id.to_s)
    end

    options[:receive_user] = current_operator if operator_state
    chat_messages.create(options)
  end

  def unmessages
    chat_messages.where("receive_user_id is null")
  end

  #获取信息
  def messages
    chat_messages
  end

  def build_items(item_ar)
    item_ar.each { |item| items.build(item) }
    self
  end

  def update_total_count
    self.items_count = items.inject(0) { |s, item| s + item.amount }
    self.total = items.inject(0) { |s, item| s + item.total }
  end

  def stotal
    (total || 0) + (delivery_price || 0)
  end

  def as_json(*args)
    attra = super *args
    attra["number"] = number
    attra["pay_manner_name"] = pay_manner.try(:name)
    attra["delivery_manner_name"] = delivery_manner.try(:name)
    attra["buyer_login"] = buyer.try(:login)
    attra["seller_name"] = seller.name
    attra["address"] = address.try(:address_only)
    attra["unmessages_count"] = unmessages.count
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

  def chat_notify(send_user, receive_user, content)
    if receive_user.present?
      url = if receive_user == buyer
        "/people/#{receive_user.login}/transactions/#{id}"
      else
        "/shops/#{seller.name}/admins/transactions/#{id}"
      end
      receive_user.notify(
        "/#{seller.im_token}/transactions/#{id}/chat",
        content,
        :order_id => id,
        :send_user => {
          :login => send_user.login,
          :id => send_user.id,
          :photos => send_user.photos.attributes
        },
        :created_at => DateTime.now,
        :url => url
      )
    else
      seller.notify(
        "/#{seller.im_token}/transactions/chat",
        _content,
        :order_id => id,
        :avatar => send_user.photos.icon,
        :unmessages_count => unmessages.count,
        :url => "/shops/#{seller.name}/admins/transactions/#{id}"
      )
    end
  end

  def valid_transfer_sheet?
    if transfer_sheet.nil?
      errors.add(:transfer_sheet, "没有汇款单号!")
    end
  end

  def valid_delivery?
    if delivery_manner.express?
      if delivery_code.blank?
        errors.add(:delivery_code, "发货运单号没有!")
      end
      if logistics_company.nil?
        errors.add(:logistics_company_id, "物流公司不存在！")
      end
    end
  end

  def valid_payment?
    if buyer.reload.money < stotal
      errors.add(:buyer, "您的金额不足!")
      false
    else
      true
    end
  end

  def valid_pay_manner?
    unless pay_manner.state
      errors.add(:pay_manner_id, "付款方式无效！")
    end
  end

  def create_transfer(options = {})
    if transfer_sheet.nil?
      TransferSheet.create(options.merge(:order_transaction => self))
    else
      transfer_sheet.update_attributes(options)
    end
  end

  def update_delivery
    if delivery_manner.present?
      if delivery_manner.local_delivery?
        self.delivery_type_id = nil
        self.delivery_price = 0
      else
        self.delivery_price = get_delivery_price(self.delivery_type_id)
      end
    end
  end

  def valid_delivery_manner?
    if delivery_manner.nil?
      errors.add(:delivery_manner_id, "没有选择运输方式!")
    end
  end

  def can_delay_sign_expired?
    undelayed_sign_state? && current_state_detail.count == 0 && DateTime.now > current_state_detail.expired - pre_delay_sign_time
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
      "pay_manner_name" => "付款方式",
      "delivery_manner_name" => "运送方式",
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

  private
  def valid_base_info?
    unless %w(order close).include?(state)
      errors.add(:pay_manner_id, "请选择付款方式!") if pay_manner.nil?
      errors.add(:address, "地址不存在！") if address.nil?
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
    activity.destroy if activity.present?
  end

  def state_title(owner)
    I18n.t("order_states.#{owner}.#{state}")
  end

  def create_the_temporary_channel
    name = self.class.to_s << "_" << number
    self.create_temporary_channel(targeable_type: "OrderTransaction", user_id: seller.owner.id, name: name)
  end

end
