class CreateCategoryPropertyValues < ActiveRecord::Migration
  def change
    create_table :category_property_values do |t|
      t.integer :category_property_id
      t.string :value

      t.timestamps
    end
  end
end
