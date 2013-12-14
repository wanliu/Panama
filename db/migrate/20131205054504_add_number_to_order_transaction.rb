class AddNumberToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :number, :string
  end
end
