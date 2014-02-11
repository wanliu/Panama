class ShopProductProductItems < ActiveRecord::Base
  attr_accessible :product_item, :shop_product

  belongs_to :product_item
  belongs_to :shop_product

  validates :product_item, :presence => true
  validates :shop_product, :presence => true
  validate :valid_already_exists?

  after_create do 
    update_product_sales
  end

  after_destroy do 
    update_product_sales
  end

  private 
  def update_product_sales
    shop_product.update_sales
  end

  def valid_already_exists?
    if ShopProductProductItems.exists?(
      [
        "shop_product_id=? and product_item_id=? and id<>?",
        shop_product_id,
        product_item_id,
        id.to_s
      ])
      errors.add(:product_item, "已经存在了,不能重复!")
    end
  end
end
