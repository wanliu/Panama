class RemoveLogisticsCompanyIdFromOrderTransaction < ActiveRecord::Migration
  def up
    remove_column :order_transactions, :logistics_company_id
  end

  def down
    add_column :order_transactions, :logistics_company_id, :string
  end
end
