class AddOperatorStateToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :operator_state, :boolean, :default => false
  end
end
