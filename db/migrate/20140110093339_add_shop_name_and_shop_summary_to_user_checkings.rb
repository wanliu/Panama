class AddShopNameAndShopSummaryToUserCheckings < ActiveRecord::Migration
  def change
    add_column :user_checkings, :shop_name, :string
    add_column :user_checkings, :shop_summary, :string
  end
end
