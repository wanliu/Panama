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
class OrderTransaction < ActiveRecord::Base
  include MessageQueue::Transaction


  attr_accessible :buyer_id, :items_count, :seller_id, :state, :total, :address_id, :delivery_type_id, :delivery_price
  # attr_accessor :total


  belongs_to :address,
          foreign_key: 'address_id'
  belongs_to :delivery_type,
          foreign_key: "delivery_type_id"

  belongs_to :seller, class_name: "Shop"
  belongs_to :buyer,
             class_name: "User"
  belongs_to :operator, class_name: "TransactionOperator"

  has_many :operators, class_name: "TransactionOperator", dependent: :destroy

  has_many  :items,
            class_name: "ProductItem",
            foreign_key: 'transaction_id',
            autosave: true,
            dependent: :destroy

  has_many :chat_messages, :as => :owner, dependent: :destroy
  has_many :state_details, class_name: "TransactionStateDetail", dependent: :destroy
  has_many :refunds, class_name: "OrderRefund", dependent: :destroy

  validates :state, :presence => true
  validates :items_count, :numericality => true
  validates :total, :numericality => true, :allow_nil => true

  validates_presence_of :buyer
  validates_presence_of :seller_id
  validates_associated :address
  # validates_presence_of :address
  validate :valid_address_and_delivery_type?

  accepts_nested_attributes_for :address
  # validates_presence_of :address

  before_validation(:on => :create) do
    update_total_count
  end

  after_create :notice_user, :notice_new_order, :state_change_detail

  def notice_user
    Notification.create!(
      :user_id => seller.user.id,
      :mentionable_user_id => buyer.id,
      :url => "/shops/#{seller.name}/admins/transactions/#{id}",
      :body => "你有新的订单")
  end

  state_machine :initial => :order do

    #确认订单 到 等待
    event :buy do
      transition [:order] => :waiting_paid
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
                  :waiting_delivery  =>  :delivery_failure,
                  :waiting_sign      =>  :complete
    end

    #退货事件
    event :returned do
      #发货失败`等待发货`签收 到 退货
      transition [:delivery_failure, :waiting_delivery, :waiting_sign, :complete] => :refund
    end

    #付款
    event :paid do
      # 等待付款 到 等待发货
      transition [:waiting_paid] => :waiting_delivery
    end

    #发货
    event :delivered do
      # 等待发货 到 等待签收
      transition [:waiting_delivery] => :waiting_sign
    end

    #签收
    event :sign do
      # 等待签收 到 完成
      transition [:waiting_sign] => :complete
    end

    after_transition :order            => :waiting_paid,
                     :waiting_paid     => :waiting_delivery do |order, transition|
      order.notice_change_seller(:name => transition.to_name)
      true
    end

    ## only for development
    if Rails.env.development?
      after_transition :waiting_paid      => :order,
                       :waiting_delivery  => :waiting_paid,
                       :waiting_sign      => :waiting_delivery do |order, transition|
        order.notice_change_seller(:name => transition.to_name, :event => :back)
      end
    end

    after_transition :waiting_delivery => :waiting_sign do |order, transition|
      order.notice_change_buyer(transition.to_name)
    end

    after_transition :waiting_paid => :waiting_delivery do |order, transaction|
      order.buyer_payment
    end

    after_transition do |order, transaction|
      if transaction.event == :back
        order.state_details.last.destroy
      else
        order.state_change_detail
      end
    end

    #商家发货延时
    after_transition :waiting_delivery => :delivery_failure do |order, transition|
      order.expired_delivery
    end

    before_transition :waiting_delivery => :waiting_sign do |order, transition|
      order.valid_delivery_code?
    end

    before_transition :waiting_paid => :waiting_delivery  do |order, transition|
      order.valid_payment?
    end

    before_transition [:delivery_failure, :waiting_delivery, :waiting_sign, :complete] => :refund do |order, transition|
      order.valid_refund?
    end

    after_transition :waiting_sign => :complete do |order, transition|
      # order
    end
  end

  def self.state_expired
    transactions = joins("left join transaction_state_details as details
      on details.order_transaction_id = order_transactions.id and
      details.state = order_transactions.state and details.expired_state=true")
    .where("details.expired <=?", DateTime.now)
    transactions.each{|t| t.fire_events!(:expired) }
    puts "=order===start: #{DateTime.now}=====count: #{transactions.count}===="
    transactions
  end

  #处理订单退货明细
  def refund_handle_product_item(refund)
    product_ids = refund.items.map{|it| it.product_id}
    product_items = items.where(:product_id => product_ids)
    if unshipped_state?
      product_items.destroy_all
      update_total_count
      refund.buyer_recharge if save
    else
      product_items.update_all(:refund_state => false)
    end
  end

  def shipped_state?
    %w(waiting_sign complete).include?(state)
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

  def order_refund_state?
    %w(delivery_failure
      waiting_delivery
      waiting_sign
      complete).include?(state)
  end

  def buyer_fire_event!(event)
    events = %w(buy back paid sign)
    filter_fire_event!(events, event)
  end

  def seller_fire_event!(event)
    events = %w(back returned delivered)
    filter_fire_event!(events, event)
  end

  def refund_items
    OrderRefundItem.where(
      :order_refund_id => refunds.map{|item| item.id})
  end

  #付款
  def buyer_payment
    buyer.payment(stotal, self)
  end

  #卖家收款
  def seller_recharge
    seller.recharge(stotal, self)
  end

  def readonly?
    false
  end

  def get_delivery_price(delivery_id)
    product_ids = items.map{|item| item.product_id}
    ProductDeliveryType.where(:product_id => product_ids)
    .select("max(delivery_price) as delivery_price")[0].delivery_price || 0
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

  def operator_connect_state
    state = current_operator.nil? || !current_operator.connect_state ? false : true
    self.update_attribute(:operator_state, state)
  end

  def operator_create(toperator_id)
    unless operator.try(:id) == toperator_id
      _operator = operators.create(operator_id: toperator_id)
      self.update_attribute(:operator_id, _operator.id)
    end
    notice_order_dispose
    operator_connect_state
  end

  #买家发送信息
  def message_create(options)
    #是否有销售组成员在线
    unless seller.seller_group_employees.any?{|u| u.connect_state }
      not_service_online(id.to_s)
    end
    operator_connect_state
    if operator_state
      options[:receive_user] = current_operator
    else
      options.delete(:receive_user)
    end
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
    attra["buyer_login"] = buyer.login
    attra["address"] = address.try(:location)
    attra["unmessages_count"] = unmessages.count
    attra
  end

  def notice_change_buyer(name)
    token = buyer.try(:im_token)
    FayeClient.send("/events/#{token}/transaction-#{id}-buyer",
                      :name => name,
                      :event => :delivered)
  end

  def notice_change_seller(options)
    token = current_operator.try(:im_token)
    FayeClient.send("/events/#{token}/transaction-#{id}-seller", options)
  end

  def valid_refund?
    # product_ids = refunds.avaliable.joins(:items) do |ref|
    #   ref.items.map{|item| item.product_id }
    # end.flatten
    # if items.where("product_id not in (?)", product_ids).first.nil?
    if items.exists?(:refund_state => true)
      errors.add(:state, "订单还有其它产品没有退货！")
      false
    else
      true
    end
  end

  def valid_delivery_code?
    if delivery_code.blank?
      errors.add(:delivery_code, "没有发货运单号!")
    end
  end

  def valid_payment?
    if buyer.reload.money < stotal
      errors.add(:buyer, "您的金额不足!")
    end
  end

  private
  def valid_address_and_delivery_type?
    unless %w(order close).include?(state)
      errors.add(:address, "地址不存在！") if address.nil?
      errors.add(:delivery_type, "请选择运送类型!") if delivery_type.nil?
    end
  end

  def notice_new_order
    FayeClient.send("/transaction/new/#{seller.id}/un_dispose", as_json)
  end

  def notice_order_dispose
    FayeClient.send("/transaction/#{seller.id}/dispose", as_json)
  end

  def filter_fire_event!(events = [], event)
    name = event.to_s
    if events.include?(name)
      fire_events!(name)
    else
      false
    end
  end
end
