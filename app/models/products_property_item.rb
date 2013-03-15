class ProductsPropertyItem < ActiveRecord::Base
  attr_accessible :product_id, :property_item_id, :title
  belongs_to :product
  belongs_to :property_item
end
