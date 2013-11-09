class AddAuditCountToShop < ActiveRecord::Migration
  def change
    add_column :shops, :audit_count, :integer, :default => 0
  end
end
