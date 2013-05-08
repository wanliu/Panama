class AddOwnerIdAndOwnerTypeToChatMessage < ActiveRecord::Migration
  def change
    add_column :chat_messages, :owner_id, :integer
    add_column :chat_messages, :owner_type, :string
  end
end
