class CreateAskBuys < ActiveRecord::Migration
  def change
    create_table :ask_buys do |t|
      t.integer :product_id
      t.string :title
      t.decimal :price, :default => 0
      t.float :amount, :default => 0
      t.text :describe
      t.integer :status, :default => 0

      t.timestamps
    end
  end
end
