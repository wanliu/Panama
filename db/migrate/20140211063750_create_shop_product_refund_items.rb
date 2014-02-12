class CreateShopProductRefundItems < ActiveRecord::Migration
  def change
    create_table :shop_product_refund_items do |t|
      t.integer :shop_product_id
      t.integer :order_refund_item_id

      t.timestamps
    end
  end
end
