class CreateOrderRefundItems < ActiveRecord::Migration
  def change
    create_table :order_refund_items do |t|
      t.integer :order_refund_id
      t.text :title
      t.decimal :amount, :default => 0
      t.decimal :price, :default => 0
      t.decimal :total, :default => 0
      t.integer :product_id

      t.timestamps
    end
  end
end
