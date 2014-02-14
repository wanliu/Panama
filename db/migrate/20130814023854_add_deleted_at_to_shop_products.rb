class AddDeletedAtToShopProducts < ActiveRecord::Migration
  def change
    add_column :shop_products, :deleted_at, :time
  end
end
