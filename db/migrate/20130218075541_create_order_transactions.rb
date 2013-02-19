class CreateOrderTransactions < ActiveRecord::Migration
  def change
    create_table :order_transactions do |t|
      t.string :state
      t.integer :items_count
      t.decimal :total
      t.integer :seller_id
      t.integer :buyer_id

      t.timestamps
    end
  end
end
