class AddPayTypeToTransferMoney < ActiveRecord::Migration
  def change
    add_column :transfer_moneys, :pay_type, :integer
  end
end
