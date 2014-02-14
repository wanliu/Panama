class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :name
      t.string :title
      t.string :property_type

      t.timestamps
    end
  end
end
