class AddOperatorIdToDirectTransaction < ActiveRecord::Migration
  def change
    add_column :direct_transactions, :operator_id, :integer
  end
end
