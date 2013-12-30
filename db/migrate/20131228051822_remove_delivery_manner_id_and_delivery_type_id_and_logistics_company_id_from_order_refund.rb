class RemoveDeliveryMannerIdAndDeliveryTypeIdAndLogisticsCompanyIdFromOrderRefund < ActiveRecord::Migration
  def up
    remove_column :order_refunds, :delivery_manner_id
    remove_column :order_refunds, :delivery_type_id
    remove_column :order_refunds, :logistics_company_id
  end

  def down
    add_column :order_refunds, :logistics_company_id, :string
    add_column :order_refunds, :delivery_type_id, :string
    add_column :order_refunds, :delivery_manner_id, :string
  end
end
