class CreateTradePayments < ActiveRecord::Migration
  def change
    create_table :trade_payments do |t|
   		t.string :serial_number, :limit => 20
  		t.decimal :money, :precision => 20, :scale => 4
  		t.text :decription
  		t.integer :order_transaction_id
  		t.integer :buyer_id
      t.timestamps
    end
  end
end
