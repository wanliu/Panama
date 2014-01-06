class ChangeOnlinePayTypeOrderTransaction < ActiveRecord::Migration
  def change
  	rename_column :order_transactions, :online_pay_type, :pay_status
  end  
end
