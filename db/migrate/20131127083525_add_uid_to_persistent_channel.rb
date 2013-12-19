class AddUidToPersistentChannel < ActiveRecord::Migration
  def change
    add_column :persistent_channels, :user_id, :integer, :limit => 11
  end
end
