class AddShopToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :shop_id, :integer
  end
end
