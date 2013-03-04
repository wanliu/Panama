class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :content
      t.integer :user_id
      t.integer :targeable_id
      t.string :targeable_type

      t.timestamps
    end
  end
end
