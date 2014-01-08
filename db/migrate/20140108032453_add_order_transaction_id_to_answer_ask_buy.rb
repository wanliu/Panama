class AddOrderTransactionIdToAnswerAskBuy < ActiveRecord::Migration
  def change
  	add_column :answer_ask_buys, :order_transaction_id, :integer
  end
end
