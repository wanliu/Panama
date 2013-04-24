class CreateChatMessages < ActiveRecord::Migration
  def change
    create_table :chat_messages do |t|
      t.integer :send_user_id
      t.integer :receive_user_id
      t.text :content

      t.timestamps
    end
  end
end
