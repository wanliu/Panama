class CreateProductPrices < ActiveRecord::Migration
  def change
    create_table :product_prices do |t|
      t.integer :product_id
      t.decimal :price, :precision => 10, :scale => 2

      t.timestamps
    end
  end
end
