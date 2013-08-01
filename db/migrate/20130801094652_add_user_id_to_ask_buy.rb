class AddUserIdToAskBuy < ActiveRecord::Migration
  def change
    add_column :ask_buys, :user_id, :integer
  end
end
