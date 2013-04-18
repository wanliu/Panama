class CreateWarehouses < ActiveRecord::Migration
  def change
    create_table :warehouses do |t|
      t.string :title
      t.integer :shop_id
      t.timestamps
    end
  end
end
