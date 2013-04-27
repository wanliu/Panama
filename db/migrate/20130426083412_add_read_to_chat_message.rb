class AddReadToChatMessage < ActiveRecord::Migration
  def change
    add_column :chat_messages, :read, :boolean, :default => false
  end
end
