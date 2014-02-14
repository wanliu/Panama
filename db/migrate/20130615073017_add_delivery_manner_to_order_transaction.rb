class AddDeliveryMannerToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :delivery_manner_id, :integer
  end
end
