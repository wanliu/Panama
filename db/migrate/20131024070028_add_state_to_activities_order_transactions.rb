class AddStateToActivitiesOrderTransactions < ActiveRecord::Migration
  def change
  	add_column :activities_order_transactions, :state, :boolean, :default => false
  end

end
