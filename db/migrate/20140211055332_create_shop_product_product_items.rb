class CreateShopProductProductItems < ActiveRecord::Migration
  def change
    create_table :shop_product_product_items do |t|
      t.integer :shop_product_id
      t.integer :product_item_id

      t.timestamps
    end
  end
end
