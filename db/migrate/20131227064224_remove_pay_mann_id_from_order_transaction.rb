class RemovePayMannIdFromOrderTransaction < ActiveRecord::Migration
  def up
    remove_column :order_transactions, :pay_manner_id
  end

  def down
    add_column :order_transactions, :pay_manner_id, :string
  end
end
