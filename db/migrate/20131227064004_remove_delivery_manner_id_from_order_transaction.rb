class RemoveDeliveryMannerIdFromOrderTransaction < ActiveRecord::Migration
  def up
    remove_column :order_transactions, :delivery_manner_id
  end

  def down
    add_column :order_transactions, :delivery_manner_id, :string
  end
end
