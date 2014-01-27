class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.integer :target_id
      t.string :name

      t.timestamps
    end
  end
end
