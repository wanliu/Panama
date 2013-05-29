#descirbe: 订单退货
#attributes
#  decription: 说明
#  total: 总金额
#  order_reason_id: 原因
#  order_transaction_id: 订单
#  buyer_id: 买家
#  seller_id: 卖家
#  operate_id: 操作员
#  refuse_reason: 拒绝理由
class OrderRefund < ActiveRecord::Base
  attr_accessible :decription, :total, :order_reason_id, :order_transaction_id

  belongs_to :order_reason
  belongs_to :order_transaction
  belongs_to :seller, class_name: "Shop"
  belongs_to :buyer, class_name: "User"
  has_many :items, class_name: "OrderRefundItem", dependent: :destroy

  validates :order_reason, :presence => true
  validates :order_transaction, :presence => true

  before_validation(:on => :create) do
    update_buyer_and_seller
  end

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
      transition :apply_refund => :refuse
    end
  end

  def update_buyer_and_seller
    self.buyer_id = order_transaction.buyer_id
    self.seller_id = order_transaction.seller_id
  end

  def create_items(_items = [])
    _items = [_items] unless _items.is_a?(Array)
    _items.each do |item|
      items.create(:product_item_id => item)
    end
  end
end
