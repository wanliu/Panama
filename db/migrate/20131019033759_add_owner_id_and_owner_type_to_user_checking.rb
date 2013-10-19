class AddOwnerIdAndOwnerTypeToUserChecking < ActiveRecord::Migration
  def change
    add_column :user_checkings, :owner_id, :integer
    add_column :user_checkings, :owner_type, :string
  end
end
