class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.string :targeable_type
      t.integer :targeable_id
      t.decimal :amount, :precision => 10, :scale => 2, :default => 0
      t.integer :status
      t.integer :shop_product_id

      t.timestamps
    end
  end
end
