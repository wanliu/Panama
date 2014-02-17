class AddOptionsToProductItem < ActiveRecord::Migration
  def change
    add_column :product_items, :options, :string
    add_index  :product_items, :options
  end
end
