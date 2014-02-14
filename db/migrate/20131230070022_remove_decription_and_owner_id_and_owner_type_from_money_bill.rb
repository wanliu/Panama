class RemoveDecriptionAndOwnerIdAndOwnerTypeFromMoneyBill < ActiveRecord::Migration
  def up
    remove_column :money_bills, :decription
    remove_column :money_bills, :owner_id
    remove_column :money_bills, :owner_type
  end

  def down
    add_column :money_bills, :owner_type, :string
    add_column :money_bills, :owner_id, :string
    add_column :money_bills, :decription, :string
  end
end
