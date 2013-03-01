class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :mentionable_user_id
      t.integer :mentionable_id
      t.string :mentionable_type

      t.timestamps
    end
  end
end
