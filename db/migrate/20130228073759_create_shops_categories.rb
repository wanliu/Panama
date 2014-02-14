class CreateShopsCategories < ActiveRecord::Migration
  def change
    create_table :shops_categories do |t|
      t.string :name
      t.string :cover
      t.integer :shop_id
      t.string :ancestry
      t.integer :ancestry_depth

      t.timestamps
    end
  end
end
