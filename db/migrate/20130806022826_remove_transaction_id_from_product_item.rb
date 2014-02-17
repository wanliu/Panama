class RemoveTransactionIdFromProductItem < ActiveRecord::Migration
  def up
    remove_column :product_items, :transaction_id
  end

  def down
    add_column :product_items, :transaction_id, :integer
  end
end
