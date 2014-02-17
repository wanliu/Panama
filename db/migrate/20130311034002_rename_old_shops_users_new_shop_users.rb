class RenameOldShopsUsersNewShopUsers < ActiveRecord::Migration
  def change
  	rename_table :shops_users, :shop_users
  end

end
