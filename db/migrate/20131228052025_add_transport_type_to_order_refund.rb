class AddTransportTypeToOrderRefund < ActiveRecord::Migration
  def change
    add_column :order_refunds, :transport_type, :string
  end
end
