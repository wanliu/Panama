class ShopProduct < ActiveRecord::Base
  attr_accessible :shop_id, :product_id, :price, :inventory

  validates :shop_id, :product_id, presence: true

  belongs_to :shop
  belongs_to :product

  def as_json(*args)
  	attra = super *args
  	attra["name"] = product.name
  	attra
  end
end
