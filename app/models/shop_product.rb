class ShopProduct < ActiveRecord::Base
  attr_accessible :shop_id, :product_id, :price, :inventory,:photos,:name

  validates :shop_id, :product_id, presence: true

  belongs_to :shop
  belongs_to :product
end
