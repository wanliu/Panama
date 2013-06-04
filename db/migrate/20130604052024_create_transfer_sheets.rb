class CreateTransferSheets < ActiveRecord::Migration
  def change
    create_table :transfer_sheets do |t|
      t.string :person
      t.string :code
      t.string :bank
      t.integer :order_transaction_id

      t.timestamps
    end
  end
end
