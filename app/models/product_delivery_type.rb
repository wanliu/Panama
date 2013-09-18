#商品物流费用
class ProductDeliveryType < ActiveRecord::Base
  attr_accessible :delivery_type_id, :product_id, :delivery_price

  belongs_to :product
  belongs_to :delivery_type
end
