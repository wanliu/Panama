class ShopProductRefundItems < ActiveRecord::Base
  attr_accessible :order_refund_item, :shop_product

  belongs_to :shop_product
  belongs_to :order_refund_item

  validates :shop_product, :presence => true
  validates :order_refund_item, :presence => true

  validate :valid_already_exists?

  after_create do 
    update_product_returned
  end

  after_destroy do 
    update_product_returned
  end

  private 
  def update_product_returned
    shop_product.update_returned
  end

  private
  def valid_already_exists?
    if ShopProductRefundItems.exists?(
      [
        "shop_product_id=? and order_refund_item_id=? and id<>?",
        shop_product_id,
        order_refund_item_id,
        id.to_s
      ])
      errors.add(:order_refund_item_id, "已经存在了,不能重复!")
    end
  end
end
