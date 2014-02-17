class ChangePricesType < ActiveRecord::Migration
  def up
  	change_column :money_bills, :money, :decimal, {:precision => 10, :scale => 2}
  	change_column :order_refund_items, :price, :decimal, {:precision => 10, :scale => 2, :default => 0}
  	change_column :order_refund_items, :total, :decimal, {:precision => 10, :scale => 2, :default => 0}
  	change_column :order_refunds, :delivery_price, :decimal, {:precision => 5, :scale => 2, :default => 0}
  	change_column :order_refunds, :total, :decimal, {:precision => 10, :scale => 2, :default => 0}
  	change_column :order_transactions, :delivery_price, :decimal, {:precision => 5, :scale => 2}
  	change_column :order_transactions, :total, :decimal, {:precision => 10, :scale => 2}

  	change_column :product_delivery_types, :delivery_price, :decimal, {:precision => 5, :scale => 2, :default => 0}
  	change_column :product_items, :price, :decimal, {:precision => 10, :scale => 2, :default => 0}
  	change_column :product_items, :total, :decimal, {:precision => 10, :scale => 2, :default => 0}
  	change_column :products, :price, :decimal, {:precision => 10, :scale => 2}
  	change_column :sub_products, :price, :decimal, {:precision => 10, :scale => 2}
  	change_column :sub_products, :quantity, :decimal, {:precision => 10, :scale => 0}
  end

  def down
  end
end
