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
  attr_accessible :decription, :total, :order_reason_id, :order_transaction_id

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

  after_create :create_state_detail

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

    before_transition :apply_refund => :failure do |refund, transition|
      refund.valid_refuse_reason?
    end

    before_transition :waiting_sign => :complete do |refund, transition|
      unless refund.order_transaction.valid_refund?
        unless refund.order_transaction.seller_fire_event!(:returned)
          refund.errors.add(:state, "确认退货出错！")
        end
      end
    end
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
    _items.each do |item|
      items.create(:product_item_id => item)
    end
  end

  def valid_refuse_reason?
    if refuse_reason.blank?
      errors.add(:refuse_reason, "没有拒绝理由!")
    end
  end

  private

  def type_fire_events!(states, event)
    if states.include?(event.to_s)
      fire_events!(event)
    else
      false
    end
  end
end
