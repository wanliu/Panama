class CreateInviteUsers < ActiveRecord::Migration
  def change
    create_table :invite_users do |t|
      t.text :body
      t.integer :user_id
      t.integer :send_user_id
      t.string :targeable_type
      t.integer :targeable_id
      t.boolean :read, :default => false
      t.integer :behavior, :default => 0

      t.timestamps
    end
  end
end
