class DropChatMessage < ActiveRecord::Migration
  def change
  	drop_table :chat_messages if table_exists?(:chat_messages)
  end
end
