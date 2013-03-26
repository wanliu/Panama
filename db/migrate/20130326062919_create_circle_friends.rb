class CreateCircleFriends < ActiveRecord::Migration
  def change
    create_table :circle_friends do |t|
      t.integer :friend_id
      t.integer :friend_type
      t.integer :circle_id

      t.timestamps
    end
  end
end
