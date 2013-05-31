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
class OrderRefund < ActiveRecord::Base
  attr_accessible :decription, :order_reason_id

  belongs_to :order_reason
  belongs_to :order_transaction
  belongs_to :seller, class_name: "Shop"
  belongs_to :buyer, class_name: "User"
  belongs_to :operator, class_name: "User"
  has_many :items, class_name: "OrderRefundItem", dependent: :destroy
  has_many :state_details, class_name: "OrderRefundStateDetail", dependent: :destroy

  validates :order_reason, :presence => true
  validates :order_transaction, :presence => true

  before_validation(:on => :create) do
    update_buyer_and_seller_and_operate
  end

  after_create :create_state_detail, :valid_order_state?

  state_machine :state, :initial => :apply_refund do

    event :agree do
      transition :apply_refund => :waiting_delivery
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

    before_transition :apply_refund => :waiting_delivery do |refund, transition|
      refund.change_order_state
    end

    before_transition :apply_refund => :failure do |refund, transition|
      refund.valid_refuse_reason?
    end

    before_transition :waiting_sign => :complete do |refund, transition|

    end
  end

  def change_order_state
    unless order_transaction.valid_refund?
      if order_transaction.seller_fire_event!(:returned)
        order_transaction.handle_product_item(items.map{|it| it.product_id})
      else
        errors.add(:state, "确认退货出错！")
      end
    end
  end

  def self.avaliable
    where("state not in (apply_refund, failure)")
  end

  def seller_fire_events!(event)
    type_fire_events!(%w(agree refuse sign), event)
  end

  def buyer_fire_events!(event)
    type_fire_events!(%w(delivered), event)
  end

  def update_buyer_and_seller_and_operate
    self.buyer_id = order_transaction.buyer_id
    self.seller_id = order_transaction.seller_id
    self.operator_id = order_transaction.operator_id
  end

  def create_state_detail
    state_details.create(:state => state)
  end

  def create_items(_items = [])
    _items = [_items] unless _items.is_a?(Array)
    _items.each do |item_id|
      product_item = order_transaction.items.find_by(:id => item_id)
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
    sum = items.inject(0){|sum, item| sum += item }
    self.update_attribute(:total, sum)
  end

  def valid_refuse_reason?
    if refuse_reason.blank?
      errors.add(:refuse_reason, "没有拒绝理由!")
    end
  end

  private

  def valid_order_state?
    if order_transaction.valid_order_refund_state?
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
