class AddPayTypeToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :pay_type, :string
  end
end
