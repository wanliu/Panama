class AddMoneyToTransferMoney < ActiveRecord::Migration
  def change
    add_column :transfer_moneys, :money, :decimal, :precision => 10, :scale => 2
  end
end
