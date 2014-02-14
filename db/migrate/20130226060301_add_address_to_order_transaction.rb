class AddAddressToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :address_id, :integer
  end
end
