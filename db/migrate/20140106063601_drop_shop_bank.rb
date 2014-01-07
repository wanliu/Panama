class DropShopBank < ActiveRecord::Migration
  def change
  	drop_table :shop_banks
  end
end
