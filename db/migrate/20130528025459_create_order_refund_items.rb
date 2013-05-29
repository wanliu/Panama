class CreateOrderRefundItems < ActiveRecord::Migration
  def change
    create_table :order_refund_items do |t|
      t.integer :order_refund_id
      t.integer :product_item_id

      t.timestamps
    end
  end
end
