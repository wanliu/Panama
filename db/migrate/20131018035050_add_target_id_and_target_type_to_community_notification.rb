class AddTargetIdAndTargetTypeToCommunityNotification < ActiveRecord::Migration
  def change
    add_column :community_notifications, :target_id, :integer
    add_column :community_notifications, :target_type, :string
  end
end
