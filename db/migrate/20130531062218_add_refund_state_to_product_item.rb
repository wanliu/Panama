class AddRefundStateToProductItem < ActiveRecord::Migration
  def change
    add_column :product_items, :refund_state, :boolean, :default => true
  end
end
