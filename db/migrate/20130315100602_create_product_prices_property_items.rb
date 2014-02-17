class CreateProductPricesPropertyItems < ActiveRecord::Migration
  def change
    create_table :product_prices_property_items, :id => false do |t|
      t.integer :product_price_id
      t.integer :property_item_id
    end
  end
end
