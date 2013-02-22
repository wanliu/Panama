class CreateProductItems < ActiveRecord::Migration
  def change
    create_table :product_items do |t|
      t.string :title
      t.decimal :amount
      t.decimal :price
      t.decimal :total
      t.integer :product_id
      t.integer :transaction_id

      t.timestamps
    end
  end
end
