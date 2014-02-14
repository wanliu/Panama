class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings do |t|
      t.integer :user_id
      t.integer :follow_id
      t.string :follow_type

      t.timestamps
    end
  end
end
