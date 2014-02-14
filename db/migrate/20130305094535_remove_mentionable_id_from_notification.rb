class RemoveMentionableIdFromNotification < ActiveRecord::Migration
  def up
    remove_column :notifications, :mentionable_id
  end

  def down
    add_column :notifications, :mentionable_id, :string
  end
end
