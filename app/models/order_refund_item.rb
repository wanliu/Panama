#encoding: utf-8
#订单退货明细
class OrderRefundItem < ActiveRecord::Base
  attr_accessible :title, :price, :amount, :product_id

  belongs_to :order_refund
  belongs_to :product

  validates :order_refund, :presence => true
  validates :product, :presence => true

  delegate :photos, :to => :product

  before_validation(:on => :create) do
    update_total
  end

  def update_total
    self.total = price * amount
  end

  private
end
