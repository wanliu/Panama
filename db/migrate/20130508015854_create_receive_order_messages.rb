class CreateReceiveOrderMessages < ActiveRecord::Migration
  def change
    create_table :receive_order_messages do |t|
      t.integer :order_transaction_id
      t.integer :send_user_id
      t.text :message
      t.boolean :state, :default => false

      t.timestamps
    end
  end
end
