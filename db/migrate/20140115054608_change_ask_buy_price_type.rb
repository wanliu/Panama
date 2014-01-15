class ChangeAskBuyPriceType < ActiveRecord::Migration
  def change
  	change_column :ask_buys, :price, :decimal, { :precision => 10, :scale => 2, :default => 0.0 }
  end
end
