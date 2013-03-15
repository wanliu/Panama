class CreateShopUserGroups < ActiveRecord::Migration
  def change
    create_table :shop_user_groups do |t|
      t.integer :shop_user_id
      t.integer :shop_group_id

      t.timestamps
    end
  end
end
