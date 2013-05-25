#产品物流费用
class ProductDeliveryType < ActiveRecord::Base
  attr_accessible :delivery_type_id, :product_id, :delivery_price
end
