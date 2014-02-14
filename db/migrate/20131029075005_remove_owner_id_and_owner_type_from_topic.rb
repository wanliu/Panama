class RemoveOwnerIdAndOwnerTypeFromTopic < ActiveRecord::Migration
  def up
    remove_column :topics, :owner_id
    remove_column :topics, :owner_type
    remove_column :topics, :status
  end

  def down
    add_column :topics, :status, :boolean
    add_column :topics, :owner_type, :string
    add_column :topics, :owner_id, :integer
  end
end
