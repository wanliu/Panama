class AddIdentityToCircleFriends < ActiveRecord::Migration
  def change
    add_column :circle_friends, :identity, :integer
  end
end
