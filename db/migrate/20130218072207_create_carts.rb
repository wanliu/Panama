class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.integer :items_count

      t.timestamps
    end
  end
end
