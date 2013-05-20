class AddDeliveryTypeToOrderTransactions < ActiveRecord::Migration
  def change
    add_column :order_transactions, :delivery_type_id, :integer
    add_column :order_transactions, :delivery_price, :decimal
  end
end
