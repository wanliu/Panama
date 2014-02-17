class AddShopsCategoryToProduct < ActiveRecord::Migration
  def change
    add_column :products, :shops_category_id, :integer
  end
end
