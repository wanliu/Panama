class ChangeWarehouseToWarehouseIdIntoItemInOut < ActiveRecord::Migration
  def change
    change_column :item_in_outs, :warehouse, :integer
    rename_column :item_in_outs, :warehouse, :warehouse_id
    rename_column :item_in_outs, :styles, :options
  end
end
