class CreateAnswerAskBuys < ActiveRecord::Migration
  def change
    create_table :answer_ask_buys do |t|
      t.integer :ask_buy_id
      t.integer :shop_product_id
      t.integer :amount,  :default => 0
      t.decimal :price,   :precision => 10, :scale => 2, :default => 0.00
      t.integer :user_id
      t.decimal :total,   :precision => 10, :scale => 2, :default => 0.00

      t.timestamps
    end
  end
end
