class CreateProductItemProperties < ActiveRecord::Migration
  def change
    create_table :product_items_properties do |t|
      t.integer :product_item_id
      t.integer :property_id

      t.timestamps
    end

  end
end
