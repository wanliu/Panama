class RemoveShopFromCategory < ActiveRecord::Migration
  def up
    remove_column :categories, :shop_id
  end

  def down
    add_column :categories, :shop_id, :integer
  end
end
