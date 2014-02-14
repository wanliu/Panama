class AddMoneyToUser < ActiveRecord::Migration
  def change
    add_column :users, :money, :decimal, :precision => 20, :scale => 4, :default => 0
  end
end
