class ProductPropertyValue < ActiveRecord::Base
  attr_accessible :product_id, :property_id

  belongs_to :property
  belongs_to :product
  # belongs_to :item, :class_name => "PropertyItem", :foreign_key => "svalue"

  def value
    case property.property_type
    when /string/
      svalue
    when /integer/
      nvalue
    when /float/, /decimal/
      dvalue
    when /datetime/
      dtvalue
    when /set/
      svalue
    end
  end

  def value=(other)
    case property.property_type
    when /string/
      send(:svalue=, other)
    when /integer/
      send(:nvalue=, other)
    when /float/, /decimal/
      send(:dvalue=, other)
    when /datetime/
      send(:dtvalue=, other)
    when /set/
      send(:svalue=, other) if property.items.select { |item| item.value == other }.size > 0
    end
  end
end
