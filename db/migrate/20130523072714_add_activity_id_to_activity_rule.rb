class AddActivityIdToActivityRule < ActiveRecord::Migration
  def change
    add_column :activity_rules, :activity_id, :integer, :limit => 11
  end
end
