class AddShopDetailToShop < ActiveRecord::Migration
  def change
  	add_column :shops, :shop_url, :string
  	add_column :shops, :shop_summary, :string
  end
end
