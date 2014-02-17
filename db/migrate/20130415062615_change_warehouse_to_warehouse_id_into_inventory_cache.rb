class ChangeWarehouseToWarehouseIdIntoInventoryCache < ActiveRecord::Migration
  def change
    change_column :inventory_caches, :warhouse, :integer
    rename_column :inventory_caches, :warhouse, :warehouse_id
    rename_column :inventory_caches, :styles, :options
  end
end
