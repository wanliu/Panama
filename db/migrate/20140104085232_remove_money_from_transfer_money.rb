class RemoveMoneyFromTransferMoney < ActiveRecord::Migration
  def up
    remove_column :transfer_moneys, :money
  end

  def down
    add_column :transfer_moneys, :money, :string
  end
end
