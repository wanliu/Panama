class ItemInOut < ActiveRecord::Base
  attr_accessible :product_id, :product_item_id, :quantity, :warehouse_id, :options

  belongs_to :warehouse
  belongs_to :product
  belongs_to :product_item
  belongs_to :inventory_cache, :primary_key => :product_id, :foreign_key => :product_id
end
