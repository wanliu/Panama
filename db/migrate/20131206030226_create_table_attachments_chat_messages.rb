class CreateTableAttachmentsChatMessages < ActiveRecord::Migration
  def change
    create_table :attachments_chat_messages do |t|
      t.integer :chat_message_id
      t.integer :attachment_id

      t.timestamps
    end
  end
end
