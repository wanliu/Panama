class AddNotificationToCommunityNotification < ActiveRecord::Migration
  def change
    add_column :community_notifications, :notification_id, :integer, :limit => 11
  end
end
