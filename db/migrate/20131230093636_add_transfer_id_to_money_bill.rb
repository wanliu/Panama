class AddTransferIdToMoneyBill < ActiveRecord::Migration
  def change
    add_column :money_bills, :transfer_id, :integer
  end
end
