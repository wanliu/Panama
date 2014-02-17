class AddNumberToOrderRefund < ActiveRecord::Migration
  def change
    add_column :order_refunds, :number, :string
  end
end
