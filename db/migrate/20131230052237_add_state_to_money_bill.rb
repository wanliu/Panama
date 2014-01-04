class AddStateToMoneyBill < ActiveRecord::Migration
  def change
    add_column :money_bills, :state, :boolean, :default => true
  end
end
