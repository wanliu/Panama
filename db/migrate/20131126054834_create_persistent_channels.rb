class CreatePersistentChannels < ActiveRecord::Migration
  def change
    create_table :persistent_channels do |t|
      t.string :name, :limit => 30
      t.integer :channel_type, :limit => 2

      t.timestamps
    end
  end
end
