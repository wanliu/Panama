class RemoveShopNameAndShopSummaryFromUserCheckings < ActiveRecord::Migration
  def up
  	remove_column :user_checkings, :shop_name
  	remove_column :user_checkings, :shop_summary
  end

  def down
  	add_column :user_checkings, :shop_name, :string
  	add_column :user_checkings, :shop_summary, :string
  end
end
