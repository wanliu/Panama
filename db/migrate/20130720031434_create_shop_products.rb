class CreateShopProducts < ActiveRecord::Migration
  def change
    create_table :shop_products do |t|
      t.references :shop
      t.references :product
      t.decimal :price, :precision => 10, :scale => 2
      t.decimal :inventory, :precision => 10, :scale => 2
      t.timestamps
    end
  end
end
