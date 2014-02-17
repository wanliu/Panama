class AddCheckedToActivities < ActiveRecord::Migration
  def change
  	add_column :activities, :status, :integer, :default => 0
  	add_column :activities, :rejected_reason, :string
  end
end
