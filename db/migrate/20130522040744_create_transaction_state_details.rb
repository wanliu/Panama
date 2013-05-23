class CreateTransactionStateDetails < ActiveRecord::Migration
  def change
    create_table :transaction_state_details do |t|
      t.integer :order_transaction_id
      t.string :state
      t.datetime :expired
      t.boolean :expired_state, :default => true

      t.timestamps
    end
  end
end
