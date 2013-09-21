class CreateAskBuyPaticipates < ActiveRecord::Migration
  def change
    create_table :ask_buy_paticipates do |t|
      t.integer :ask_buy_id
      t.integer :user_id
      t.integer :shop_id

      t.timestamps
    end
  end
end
