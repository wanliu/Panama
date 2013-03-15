class AddTitleToProductPropertyItem < ActiveRecord::Migration
  def change
    add_column :products_property_items, :title, :string
    remove_column :products_property_items, :created_at
    remove_column :products_property_items, :updated_at
  end
end
