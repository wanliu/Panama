class RemoveShopProductIdFromProductItem < ActiveRecord::Migration
  def up
    remove_column :product_items, :shop_product_id
  end

  def down
    add_column :product_items, :shop_product_id, :integer
  end
end
