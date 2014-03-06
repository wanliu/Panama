class AddNumberToOrderRefund < ActiveRecord::Migration
  def change
    add_column :order_refunds, :number, :string, :unique => true
  end
end
