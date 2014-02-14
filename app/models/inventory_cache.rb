class InventoryCache < ActiveRecord::Base
  attr_accessible :count, :product_id, :styles, :warhouse, :last_time

  belongs_to :product
  has_many   :item_in_outs

end
