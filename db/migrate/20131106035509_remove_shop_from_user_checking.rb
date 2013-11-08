class RemoveShopFromUserChecking < ActiveRecord::Migration
  def up
  	remove_column :user_checkings, :shop_photo
  	remove_column :user_checkings, :shop_name
  	remove_column :user_checkings, :shop_url
  	remove_column :user_checkings, :shop_summary
  	remove_column :user_checkings, :owner_id
  	remove_column :user_checkings, :owner_type
  end

  def down
  	add_column :user_checkings, :shop_photo, :string
  	add_column :user_checkings, :shop_name, :string
  	add_column :user_checkings, :shop_url, :string
  	add_column :user_checkings, :shop_summary, :string
  	add_column :user_checkings, :owner_id, :integer
  	add_column :user_checkings, :owner_type, :string
  end
end
