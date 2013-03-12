class InventoryCache < ActiveRecord::Base
  attr_accessible :count, :product_id, :styles, :warhouse, :last_time
end
