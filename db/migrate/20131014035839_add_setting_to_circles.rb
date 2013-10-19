class AddSettingToCircles < ActiveRecord::Migration
  def change
  	add_column :circles, :description, :string
  	add_column :circles, :city_id, :integer
  	add_column :circles, :setting_id, :integer
  	add_column :circles, :created_type, :string, :default => "basic"
  end
end
