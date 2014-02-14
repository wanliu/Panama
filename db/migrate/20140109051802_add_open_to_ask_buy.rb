class AddOpenToAskBuy < ActiveRecord::Migration
  def change
  	add_column :ask_buys, :open, :boolean, :default => true
  end
end
