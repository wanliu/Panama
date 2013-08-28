class AddDeletedAtToShopBank < ActiveRecord::Migration
  def change
    add_column :shop_banks, :deleted_at, :time
  end
end
