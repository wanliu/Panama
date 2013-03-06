class Property < ActiveRecord::Base
  attr_accessible :name, :property_type, :title

  attr_accessor :value
  has_and_belongs_to_many :products
  has_and_belongs_to_many :categories
  has_many :items, :class_name => "PropertyItem"

end
