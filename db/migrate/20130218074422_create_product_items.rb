class CreateProductItems < ActiveRecord::Migration
  def change
    create_table :product_items do |t|
      t.string :title
      t.decimal :amount, :default => 0
      t.decimal :price, :default => 0
      t.decimal :total, :default => 0
      t.integer :product_id
      t.integer :transaction_id

      t.timestamps
    end
  end
end
