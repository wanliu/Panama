class CreateCircles < ActiveRecord::Migration
  def change
    create_table :circles do |t|
      t.string :name
      t.integer :owner_id
      t.string :owner_type

      t.timestamps
    end
  end
end
