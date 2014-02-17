class AddActivityTypeToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :activity_type, :string, :limit => 14
  end
end
