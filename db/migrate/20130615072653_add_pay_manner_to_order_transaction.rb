class AddPayMannerToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :pay_manner_id, :integer
  end
end
