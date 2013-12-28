class AddTransportTypeToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :transport_type, :string
  end
end
