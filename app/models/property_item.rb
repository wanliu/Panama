class PropertyItem < ActiveRecord::Base
  attr_accessible :property_id, :value

  has_many   :values, :class_name => "ProductPropertyValue", :foreign_key => "svalue"
  belongs_to :property
  has_and_belongs_to_many :products
end
