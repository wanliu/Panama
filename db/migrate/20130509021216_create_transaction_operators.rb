class CreateTransactionOperators < ActiveRecord::Migration
  def change
    create_table :transaction_operators do |t|
      t.integer :order_transaction_id
      t.integer :operator_id

      t.timestamps
    end
  end
end
