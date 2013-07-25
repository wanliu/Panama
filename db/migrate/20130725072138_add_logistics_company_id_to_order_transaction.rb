class AddLogisticsCompanyIdToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :logistics_company_id, :integer
  end
end
