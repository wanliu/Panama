class CreateOrderRefunds < ActiveRecord::Migration
  def change
    create_table :order_refunds do |t|
      t.integer :order_reason_id
      t.text :decription
      t.integer :order_transaction_id
      t.decimal :total, :default => 0
      t.string :state
      t.integer :buyer_id
      t.integer :seller_id
      t.text :refuse_reason
      t.integer :operator_id

      t.timestamps
    end
  end
end
