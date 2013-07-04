class AddShopIdToProductItem < ActiveRecord::Migration
  def change
  	add_column :product_items, :shop_id, :integer
  end
end
