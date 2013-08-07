class AddStateToDirectTransaction < ActiveRecord::Migration
  def change
    add_column :direct_transactions, :state, :integer
  end
end
