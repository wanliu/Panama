class RemoveShopProductIdFromProductItem < ActiveRecord::Migration
  def up
  	if column_exists?(:product_items, :shop_product_id)
    	remove_column :product_items, :shop_product_id
    end
  end

  def down
    add_column :product_items, :shop_product_id, :integer
  end
end
