class AddRejectedTimesAndCheckedToUserCheckings < ActiveRecord::Migration
  def change
  	add_column :user_checkings, :checked, :boolean, default: false
  	add_column :user_checkings, :rejected_times, :integer, default: 0
  end
end
