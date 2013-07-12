#encoding: utf-8
#descirbe: 订单退货
#attributes
#  decription: 说明
#  total: 总金额
#  order_reason_id: 原因
#  order_transaction_id: 订单
#  buyer_id: 买家
#  seller_id: 卖家
#  operator_id: 操作员
#  refuse_reason: 拒绝理由
#  delivery_price: 退运费
#  delivery_code: 运单号
class OrderRefund < ActiveRecord::Base
  include MessageQueue::OrderRefund

  attr_accessible :decription, :order_reason_id, :delivery_price

  belongs_to :order_reason
  belongs_to :order, :foreign_key => "order_transaction_id", :class_name => "OrderTransaction"
  belongs_to :seller, class_name: "Shop"
  belongs_to :buyer, class_name: "User"
  belongs_to :operator, class_name: "User"
  has_many :items, class_name: "OrderRefundItem", dependent: :destroy
  has_many :state_details, class_name: "OrderRefundStateDetail", dependent: :destroy

  validates :order_reason, :presence => true
  validates :order, :presence => true
  validates :order_transaction_id, :uniqueness => { message: "该单已经在退货之中" }

  before_validation(:on => :create) do
    update_buyer_and_seller_and_operate
  end

  after_create :create_state_detail, :valid_shipped_order_state?

  state_machine :state, :initial => :apply_refund do

    event :shipped_agree do
      transition [:apply_refund, :apply_failure] => :waiting_delivery
    end

    event :unshipped_agree do
      transition [:apply_refund, :apply_failure] => :complete
    end

    event :expired do
      transition :apply_refund => :apply_failure,
                 :waiting_delivery => :close,
                 :waiting_sign => :complete
    end

    event :delivered do
      transition :waiting_delivery => :waiting_sign
    end

    event :sign do
      transition :waiting_sign => :complete
    end

    event :refuse do
      transition :apply_refund => :failure
    end

    after_transition do |refund, transition|
      refund.create_state_detail
    end

    before_transition :apply_refund => :failure do |refund, transition|
      refund.valid_refuse_reason?
    end

    before_transition :apply_refund => :waiting_delivery,
                      :apply_failure => :waiting_delivery do |refund, transition|
      refund.validate_shipped_order_state?
    end

    before_transition :apply_failure => :complete,
                      :apply_refund => :complete do |refund, transition|
      refund.valid_unshipped_order_state?
    end

    before_transition :waiting_delivery => :waiting_sign do |refund, transition|
      refund.valid_delivery_code?
    end

    after_transition :apply_refund => [:waiting_delivery, :complete],
                     :apply_failure => [:waiting_delivery, :complete] do |refund, transition|
      refund.handle_detail_return_money
      refund.change_order_state
    end

    after_transition :waiting_sign => :complete do |refund, transition|
      refund.seller_refund_money
      refund.handle_product_item
      refund.change_order_state
    end

    after_transition :apply_refund => :apply_failure do |refund, transition|
      refund.apply_failure_notice
    end
  end

  def self.state_expired
    refunds = find(:all,
      :joins => "left join order_refund_state_details as detail
      on  detail.order_refund_id = order_refunds.id and
      detail.expired_state=true and
      detail.state=order_refunds.state",
      :conditions => ["detail.expired<=?", DateTime.now],
      :readonly => false)
    refunds.each{|ref| ref.fire_events!(:expired) }
    puts "=refund===start: #{DateTime.now}=====count: #{refunds.count}===="
    refunds
  end

  def current_state_detail
    state_details.find_by(:state => state)
  end

  def change_order_state
    if order.valid_refund?
      unless order.seller_fire_event!(:returned)
        errors.add(:state, "确认退货出错！")
      end
    end
  end

  def handle_detail_return_money
    order.refund_handle_detail_return_money(self)
  end

  def handle_product_item
    order.refund_handle_product_item(self)
  end

  def self.avaliable
    where("state not in ('apply_refund', 'failure')")
  end

  def seller_fire_events!(event)
    type_fire_events!(%w(shipped_agree unshipped_agree  refuse sign), event)
  end

  def buyer_fire_events!(event)
    type_fire_events!(%w(delivered), event)
  end

  def update_buyer_and_seller_and_operate
    self.buyer_id = order.try(:buyer_id)
    self.seller_id = order.try(:seller_id)
    self.operator_id = order.try(:operator_id)
  end

  def create_state_detail
    state_details.update_all(:expired_state => false)
    state_details.create(:state => state)
  end

  def create_items(_items = [])
    _items = [_items] unless _items.is_a?(Array)
    _items.each do |item_id|
      product_item = order.items.find_by(:id => item_id, :refund_state => true)
      if product_item.present?
        items.create(
          :title => product_item.title,
          :amount => product_item.amount,
          :price => product_item.price,
          :product_id => product_item.product_id)
      end
    end
    update_total
  end

  def update_total
    sum = items.inject(0){|sum, item| sum += item.total }
    self.update_attribute(:total, sum)
  end

  def stotal
    total + delivery_price
  end

  #退款
  def buyer_recharge
    order.buyer.recharge(stotal, self)
  end

  def seller_payment
    order.seller.user.payment(stotal, self)
  end

  #卖家退款
  def seller_refund_money
    if order.complete_state?
      MoneyBill.transaction do
        buyer_recharge
        seller_payment
      end
    elsif order.waiting_sign_state? && !order.payment.cash_on_delivery?
      buyer_recharge
    end
  end

  def valid_delivery_code?
    if delivery_code.blank?
      errors.add(:delivery_code, "发货单号不能为空！")
    end
  end

  def valid_refuse_reason?
    if refuse_reason.blank?
      errors.add(:refuse_reason, "请填写拒绝理由!")
    end
  end

  def validate_shipped_order_state?
    unless order.shipped_state?
      errors.add(:state, "卖家还没有发货!")
    end
  end

  def valid_unshipped_order_state?
    unless order.unshipped_state?
      errors.add(:state, "卖家已经发送了!")
    end
  end


  private
  def valid_shipped_order_state?
    unless order.order_refund_state?
      errors.add(:order_transaction_id, "订单属于不能退货状态！")
    end
  end

  def type_fire_events!(states, event)
    if states.include?(event.to_s)
      fire_events!(event)
    else
      false
    end
  end
end
