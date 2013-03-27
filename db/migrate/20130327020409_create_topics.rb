class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.integer :user_id
      t.integer :owner_id
      t.string :owner_type
      t.string :content
      t.string :content_html

      t.timestamps
    end
  end
end
