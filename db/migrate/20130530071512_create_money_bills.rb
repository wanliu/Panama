class CreateMoneyBills < ActiveRecord::Migration
  def change
    create_table :money_bills do |t|
      t.string :serial_number
      t.decimal :money, :precision => 10, :scale => 2
      t.text :decription
      t.integer :user_id
      t.integer :owner_id
      t.string :owner_type

      t.timestamps
    end
  end
end
