class AddStatusToAnswerAskBuy < ActiveRecord::Migration
  def change
  	add_column :answer_ask_buys, :status, :integer, :default => 0
  end
end
