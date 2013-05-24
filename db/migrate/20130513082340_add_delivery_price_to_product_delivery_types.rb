class AddDeliveryPriceToProductDeliveryTypes < ActiveRecord::Migration
  def change
    add_column :product_delivery_types, :delivery_price, :decimal, :default => 0
  end
end
