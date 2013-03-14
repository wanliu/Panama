class ItemInOut < ActiveRecord::Base
  attr_accessible :product_id, :product_item_id, :quantity, :warehouse
end
