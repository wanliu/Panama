class RemoveOperatorIdFormOrderTransaction < ActiveRecord::Migration
	def change
		remove_column :order_transactions, :operator_id
	end
end
