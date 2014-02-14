class AddDeliveryCodeToOrderRefund < ActiveRecord::Migration
  def change
    add_column :order_refunds, :delivery_code, :string
  end
end
