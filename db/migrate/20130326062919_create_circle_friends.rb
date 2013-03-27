class CreateCircleFriends < ActiveRecord::Migration
  def change
    create_table :circle_friends do |t|
      t.integer :user_id
      t.integer :circle_id

      t.timestamps
    end
  end
end
