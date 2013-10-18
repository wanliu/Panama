class AddCircleIdToCommunityNotification < ActiveRecord::Migration
  def change
    add_column :community_notifications, :circle_id, :integer
  end
end
