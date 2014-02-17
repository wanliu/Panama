class RemoveRefundStateFromProductItem < ActiveRecord::Migration
  def up
    remove_column :product_items, :refund_state
  end

  def down
    add_column :product_items, :refund_state, :boolean
  end
end
