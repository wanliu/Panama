class ChangeProductItemsAmount < ActiveRecord::Migration
  def change
    change_column :product_items, :amount, :integer, :default => 0
  end
end
