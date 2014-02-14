class ChangeAmountFromAskBuy < ActiveRecord::Migration
  def change
    change_column :ask_buys, :amount, :integer, :default => 0
  end
end
