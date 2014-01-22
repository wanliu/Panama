class AddSalesToShopProduct < ActiveRecord::Migration
  def change
    add_column :shop_products, :sales, :decimal, :precision => 10, :scale => 2, :default => 0
    add_column :shop_products, :returned, :decimal, :precision => 10, :scale => 2, :default => 0
  end
end
