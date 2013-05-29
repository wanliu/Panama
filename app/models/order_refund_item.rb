#encoding: utf-8
#订单退货明细
class OrderRefundItem < ActiveRecord::Base
  attr_accessible :order_refund_id, :product_item_id

  belongs_to :order_refund
  belongs_to :product_item

  validates :product_item, :presence => true
  validates :order_refund, :presence => true

  validate :valid_product_item_exists?

  private
  def valid_product_item_exists?
    if order_refund.order_transaction.items.find_by(:id => product_item_id).nil?
      errors.add(:product_item, "订单明细不存在!")
    end
  end
end
