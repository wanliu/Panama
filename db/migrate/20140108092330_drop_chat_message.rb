class DropChatMessage < ActiveRecord::Migration
  def change
  	drop_table :chat_messages
  end
end
