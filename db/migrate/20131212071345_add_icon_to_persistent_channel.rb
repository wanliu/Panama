class AddIconToPersistentChannel < ActiveRecord::Migration
  def change
    add_column :persistent_channels, :icon, :string, :limit => 255
  end
end
