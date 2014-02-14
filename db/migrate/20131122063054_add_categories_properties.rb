class AddCategoriesProperties < ActiveRecord::Migration
  def change
  	add_column :categories_properties, :filter_state, :boolean, :default => false
  end
end
