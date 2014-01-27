class AddTargetTypeToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :target_type, :string
  end
end
