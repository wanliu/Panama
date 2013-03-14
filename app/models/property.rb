class Property < ActiveRecord::Base
  attr_accessible :name, :property_type, :title#, :items_attributes

  attr_accessor :value
  has_and_belongs_to_many :products
  has_and_belongs_to_many :categories
  has_many :items, :class_name => "PropertyItem", dependent: :destroy
  # accepts_nested_attributes_for :items

  validates :name, uniqueness: true
  validates :property_type, inclusion: { in: %w(string set datetime integer float decimal) }

  def property_types
  	%w(string set datetime integer float decimal)
  end

end
