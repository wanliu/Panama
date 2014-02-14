class AddOperatorIdToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :operator_id, :integer
  end
end
