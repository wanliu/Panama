class AddOrderStateToOrderRefund < ActiveRecord::Migration
  def change
    add_column :order_refunds, :order_state, :string
  end
end
