class ShopProduct < ActiveRecord::Base
  attr_accessible :shop_id, :product_id, :price, :inventory

  validates :shop_id, :product_id, presences: true

  belongs_to :shop
  belongs_to :product
end
