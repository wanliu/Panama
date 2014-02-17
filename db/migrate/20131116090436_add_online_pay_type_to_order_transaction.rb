class AddOnlinePayTypeToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :online_pay_type, :integer, :default => 0
  end
end
