class DropShopBank < ActiveRecord::Migration
  def change
  	drop_table :shop_banks if table_exists?(:shop_banks)
  end
end
