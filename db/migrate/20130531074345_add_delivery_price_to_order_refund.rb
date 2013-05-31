class AddDeliveryPriceToOrderRefund < ActiveRecord::Migration
  def change
    add_column :order_refunds, :delivery_price, :decimal, :default => 0
  end
end
