class RenameBuyerIdToUserIdFromTradeIncome < ActiveRecord::Migration
  def change
  	rename_column :trade_incomes, :buyer_id, :user_id
  end
end
