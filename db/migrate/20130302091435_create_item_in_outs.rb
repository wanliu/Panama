class CreateItemInOuts < ActiveRecord::Migration
  def change
    create_table :item_in_outs do |t|
      t.integer :product_id
      t.integer :product_item_id
      t.decimal :quantity
      t.string :styles
      t.string :warehouse

      t.timestamps
    end
  end
end
