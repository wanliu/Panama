class AddLogisticsCompanyIdToOrderRefund < ActiveRecord::Migration
  def change
    add_column :order_refunds, :logistics_company_id, :integer
  end
end
