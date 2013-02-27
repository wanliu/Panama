class CreateSubProducts < ActiveRecord::Migration
  def change
    create_table :sub_products do |t|
      t.float :price
      t.float :quantity
      t.references :product, null: false

      t.timestamps
    end
  end
end
