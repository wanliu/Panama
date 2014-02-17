class CreateProductItemPropertyItem < ActiveRecord::Migration
  def change
    create_table :product_items_property_items do |t|
      t.integer :product_item_id
      t.integer :property_item_id
      t.string  :title
      t.timestamps
    end
  end
end
