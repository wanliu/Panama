class AddCountToTransactionStateDetails < ActiveRecord::Migration
  def change
  	add_column :transaction_state_details, :count, :integer, :default => 0
  end
end
