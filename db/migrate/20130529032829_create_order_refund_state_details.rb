class CreateOrderRefundStateDetails < ActiveRecord::Migration
  def change
    create_table :order_refund_state_details do |t|
      t.integer :order_refund_id
      t.string :state
      t.datetime :expired
      t.boolean :expired_state, :default => true

      t.timestamps
    end
  end
end
