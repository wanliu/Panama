class StylePair < ActiveRecord::Base
  attr_accessible :style_item_id, :sub_product_id

  belongs_to :style_item
  belongs_to :sub_product
end
