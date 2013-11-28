class CategoryPropertyValue < ActiveRecord::Base
  attr_accessible :category_property_id, :value

  belongs_to :category_property,
  class_name: "CategoriesProperty", foreign_key: :category_property_id

  validates :value, :presence => true
  validates :category_property, :presence => true

end
