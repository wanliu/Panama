class AddCartToProductItem < ActiveRecord::Migration
  def change
    add_column :product_items, :cart_id, :integer
  end
end
