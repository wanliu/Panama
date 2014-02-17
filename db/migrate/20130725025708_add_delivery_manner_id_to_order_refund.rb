class AddDeliveryMannerIdToOrderRefund < ActiveRecord::Migration
  def change
    add_column :order_refunds, :delivery_manner_id, :integer
  end
end
