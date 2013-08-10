class AddTypeToNotifictions < ActiveRecord::Migration
  def change
  	add_column :notifications, :targeable_type, :string
  	add_column :notifications, :targeable_id, :integer
  end
end
