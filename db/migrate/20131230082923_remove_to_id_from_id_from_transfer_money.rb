class RemoveToIdFromIdFromTransferMoney < ActiveRecord::Migration
  def up
    remove_column :transfer_moneys, :to_id
    remove_column :transfer_moneys, :from_id
  end

  def down
    add_column :transfer_moneys, :from_id, :string
    add_column :transfer_moneys, :to_id, :string
  end
end
