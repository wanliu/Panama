class AddMoneyToUser < ActiveRecord::Migration
  def change
    add_column :users, :money, :decimal, :precision => 20, :scale => 4
  end
end
