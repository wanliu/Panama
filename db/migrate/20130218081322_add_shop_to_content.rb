class AddShopToContent < ActiveRecord::Migration
  def change
    add_column :contents, :shop_id, :integer
  end
end
