class PropertyValue < ActiveRecord::Base
  attr_accessible :valuable, :valuable_type, :valuable_id, :property_id

  belongs_to :property
  belongs_to :valuable, :polymorphic => true
  # belongs_to :product
  # belongs_to :item, :class_name => "PropertyItem", :foreign_key => "svalue"

  def value
    send property.type_field
  end

  def value=(other)
    field = property.type_field
    # if field == :svalue
    #   item = valuable.property_items.select{|item| item.id.to_s == other}.first
    #   if item.present?
    #     send(:svalue=, item.value) #if valuable.property_items.select { |item| item.value == other }.size > 0
    #   end
    # else
      send("#{field}=", other)
    # end
  end
end
