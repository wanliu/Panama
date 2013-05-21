class CreateDialogues < ActiveRecord::Migration
  def change
    create_table :dialogues do |t|
      t.integer :user_id
      t.integer :friend_id
      t.string :token

      t.timestamps
    end
  end
end
