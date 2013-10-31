class CreateCircleCategories < ActiveRecord::Migration
  def change
    create_table :circle_categories do |t|
      t.integer :circle_id
      t.string :name

      t.timestamps
    end
  end
end
