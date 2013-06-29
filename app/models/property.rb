class Property < ActiveRecord::Base
  attr_accessible :id, :name, :property_type, :title#, :items_attributes

  attr_accessor :value
  has_and_belongs_to_many :products
  has_and_belongs_to_many :categories
  has_many :items, :class_name => "PropertyItem", dependent: :destroy
  # accepts_nested_attributes_for :items

  validates :name, uniqueness: true
  validates :property_type, inclusion: { in: %w(string integer decimal datetime set float) }


end
