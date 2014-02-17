class MoveProductPropertyValueToPropertyValue < ActiveRecord::Migration
  def change
    rename_table  :product_property_values, :property_values
    add_column    :property_values, :valuable_type, :string
    rename_column :property_values, :product_id, :valuable_id
    PropertyValue.update_all("valuable_type = 'Product'")
  end
end
