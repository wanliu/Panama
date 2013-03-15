class AddTitleToProductPropertyItem < ActiveRecord::Migration
  def up
    add_column :products_property_items, :title, :string
    remove_column :products_property_items, :created_at
    remove_column :products_property_items, :updated_at
  end

  def down
    remove_column :products_property_items, :title
    add_column :products_property_items, :created_at, :datetime
    add_column :products_property_items, :updated_at, :datetime
  end
end
