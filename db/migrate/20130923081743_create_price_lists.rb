class CreatePriceLists < ActiveRecord::Migration
  def change
    create_table :price_lists do |t|
      t.integer :people_number
      t.decimal :price
      t.integer :activity_id

      t.timestamps
    end
  end
end
