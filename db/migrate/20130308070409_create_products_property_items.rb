class CreateProductsPropertyItems < ActiveRecord::Migration
  def change
    create_table :products_property_items do |t|
      t.integer :product_id
      t.integer :property_item_id

      t.timestamps
    end
  end
end
