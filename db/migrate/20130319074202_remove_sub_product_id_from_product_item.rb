class RemoveSubProductIdFromProductItem < ActiveRecord::Migration
  def up
    add_column :product_items, :product_id, :integer
    remove_column :product_items, :sub_product_id
  end

  def down
    add_column :product_items, :sub_product_id, :integer
    remove_column :product_items, :product_id
  end
end
