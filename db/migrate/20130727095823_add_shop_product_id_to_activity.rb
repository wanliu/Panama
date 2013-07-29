class AddShopProductIdToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :shop_product_id, :integer
  end
end
