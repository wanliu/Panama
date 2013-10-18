class AddSendIdToCommunityNotification < ActiveRecord::Migration
  def change
    add_column :community_notifications, :send_user_id, :integer
  end
end
