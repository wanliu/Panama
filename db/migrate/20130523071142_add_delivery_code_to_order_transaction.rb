class AddDeliveryCodeToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :delivery_code, :string
  end
end
