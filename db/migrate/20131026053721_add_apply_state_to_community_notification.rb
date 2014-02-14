class AddApplyStateToCommunityNotification < ActiveRecord::Migration
  def change
    add_column :community_notifications, :apply_state, :boolean
  end
end
