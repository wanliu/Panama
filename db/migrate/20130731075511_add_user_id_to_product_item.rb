class AddUserIdToProductItem < ActiveRecord::Migration
  def change
    add_column :product_items, :user_id, :integer
  end
end
