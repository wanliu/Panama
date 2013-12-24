class AlterTokenLengthToTepmoraryChannels < ActiveRecord::Migration
  def up
  	change_column :temporary_channels, :token, :string, :limit => 45
  end

  def down
  	change_column :temporary_channels, :token, :string, :limit => 36
  end
end
