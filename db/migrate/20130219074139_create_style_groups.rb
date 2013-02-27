class CreateStyleGroups < ActiveRecord::Migration
  def change
    create_table :style_groups do |t|
      t.string :name
      t.references :product, null: false

      t.timestamps
    end
  end
end
