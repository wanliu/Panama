class RemoveMentionableTypeFromNotification < ActiveRecord::Migration
  def up
    remove_column :notifications, :mentionable_type
  end

  def down
    add_column :notifications, :mentionable_type, :string
  end
end
