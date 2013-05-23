class CreateTradeIncomes < ActiveRecord::Migration
  def change
    create_table :trade_incomes do |t|
    	t.string :serial_number, :limit =>20
  		t.decimal :money, :precision => 20, :scale => 4
  		t.text :decription
  		t.integer :bank_id
  		t.integer :buyer_id
  		t.timestamps
    end
  end
end
