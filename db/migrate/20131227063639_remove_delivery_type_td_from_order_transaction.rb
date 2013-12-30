class RemoveDeliveryTypeTdFromOrderTransaction < ActiveRecord::Migration
  def change
  	remove_column :order_transactions, :delivery_type_id
  end
end
