#encoding: utf-8
#订单退货明细
class OrderRefundItem < ActiveRecord::Base
  attr_accessible :title, :price, :amount, :product_id

  belongs_to :order_refund
  belongs_to :product
  has_many :returned_items, :class_name => "ShopProductRefundItems", :dependent => :destroy

  validates :order_refund, :presence => true
  validates :product, :presence => true  

  delegate :photos, :to => :product

  before_validation(:on => :create) do
    update_total
  end

  def create_product_returned
    returned_items.create(:shop_product => shop_product)
  end

  def update_total
    self.total = price * amount
  end

  def shop_product
    ShopProduct.find_by(
      :product_id => product_id,
      :shop_id => order_refund.seller.id)
  end

  private
end
