class AddAdressIdAndDeliveryCodeToDirectTransaction < ActiveRecord::Migration
  def change
    add_column :direct_transactions, :address_id, :integer
    add_column :direct_transactions, :delivery_code, :string
  end
end
