class CreatePropertyItems < ActiveRecord::Migration
  def change
    create_table :property_items do |t|
      t.integer :property_id
      t.string :value

      t.timestamps
    end
  end
end
