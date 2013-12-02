class Property < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Tire::Model::UpdateByQuery

  attr_accessible :id, :name, :property_type, :title#, :items_attributes

  attr_accessor :value
  has_and_belongs_to_many :products
  has_and_belongs_to_many :categories
  has_many :items, :class_name => "PropertyItem", dependent: :destroy
  has_many :values, :class_name => "PropertyValue", dependent: :destroy
  # accepts_nested_attributes_for :items

  validates :name, uniqueness: true, presence: true
  validates :property_type, inclusion: { in: %w(string integer decimal datetime set float) }

  after_save do
    self.name.strip!
    self.title.strip!
  end

  def values_names
  	values.select("distinct #{type_field}, property_id")
  end

  def type_field
    case property_type
    when /string/
      :svalue
    when /integer/
      :nvalue
    when /float/, /decimal/
      :dvalue
    when /datetime/
      :dtvalue
    when /set/
      :svalue
    end
  end
end
