class CreateFriendGroupUsers < ActiveRecord::Migration
  def change
    create_table :friend_group_users do |t|
      t.integer :friend_group_id
      t.integer :user_id

      t.timestamps
    end
  end
end
