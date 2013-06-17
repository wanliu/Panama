class AddTransferSheetToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :transfer_sheet_id, :integer
  end
end
