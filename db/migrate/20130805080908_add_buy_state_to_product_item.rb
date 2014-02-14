class AddBuyStateToProductItem < ActiveRecord::Migration
  def change
    add_column :product_items, :buy_state, :integer
  end
end
