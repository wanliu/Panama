class CreateCategoriesProperties < ActiveRecord::Migration
  def change
    create_table :categories_properties do |t|
      t.integer :category_id
      t.integer :property_id

      t.timestamps
    end
  end
end
