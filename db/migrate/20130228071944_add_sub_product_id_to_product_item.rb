class AddSubProductIdToProductItem < ActiveRecord::Migration
  def change
    add_column :product_items, :sub_product_id, :integer
    remove_column :product_items, :product_id
  end
end
