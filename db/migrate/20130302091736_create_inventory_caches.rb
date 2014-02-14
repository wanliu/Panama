class CreateInventoryCaches < ActiveRecord::Migration
  def change
    create_table :inventory_caches do |t|
      t.integer :product_id
      t.string :styles
      t.decimal :count
      t.string :warhouse
      t.decimal :last_time, :precision => 20, :scale => 10
      # t.float :last_time
    end

    add_index :inventory_caches, :product_id
    add_index :inventory_caches, :styles
    add_index :inventory_caches, :warhouse
    add_index :inventory_caches, :last_time
  end
end
