class CreateTemporaryChannels < ActiveRecord::Migration
  def change
    create_table :temporary_channels do |t|
      t.string :name, :limit => 30
      t.integer :channel_type, :limit => 2
      t.integer :user_id, :limit => 11
      t.string :token, :limit => 36
      t.references :targeable, :polymorphic => true

      t.timestamps
    end
  end
end
