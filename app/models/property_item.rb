class PropertyItem < ActiveRecord::Base
  attr_accessible :id, :property_id, :value

  has_many   :values, :class_name => "PropertyValue", :foreign_key => "svalue"
  belongs_to :property
  has_and_belongs_to_many :products
  has_and_belongs_to_many :product_prices

  after_save do |item|
    if respond_to?(:products_property_items_id)
      ppid = ActiveRecord::Base.connection.quote(products_property_items_id)
      _title = ActiveRecord::Base.connection.quote(title)
      update_sql = "update products_property_items set title=#{_title} where id=#{ppid}"
      ActiveRecord::Base.connection.execute(update_sql)
    end
  end

  def title
    read_attribute(:title) || value
  end
end
