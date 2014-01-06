class AddUserIdToTransferMoney < ActiveRecord::Migration
  def change
    add_column :transfer_moneys, :user_id, :integer
  end
end
