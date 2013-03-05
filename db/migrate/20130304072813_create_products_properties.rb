class CreateProductsProperties < ActiveRecord::Migration
  def change
    create_table :products_properties do |t|
      t.integer :product_id
      t.integer :property_id

      t.timestamps
    end
  end
end
