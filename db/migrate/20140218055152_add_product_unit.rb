# coding: utf-8
class AddProductUnit < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.string :code
      t.string :name, :default => "件"
      t.integer :child_id
      t.float :percentage, :default => 1
    end

    add_column :products, :unit_id, :integer
    add_column :shop_products, :inventory_unit_id, :integer
  end
end
