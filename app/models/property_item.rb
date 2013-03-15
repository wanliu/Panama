class PropertyItem < ActiveRecord::Base
  attr_accessible :property_id, :value

  has_many   :values, :class_name => "ProductPropertyValue", :foreign_key => "svalue"
  belongs_to :property
  has_and_belongs_to_many :products


  after_save do |item|
    ppid = products_property_items_id if respond_to?(:products_property_items_id)
    ProductsPropertyItem.update(ppid, :title => title) if respond_to?(:title)
  end

  def title
    read_attribute(:title) || value
  end
end
