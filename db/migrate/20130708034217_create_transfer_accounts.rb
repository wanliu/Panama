class CreateTransferAccounts < ActiveRecord::Migration
  def change
    create_table :transfer_accounts do |t|
      t.string :name
      t.string :number
      t.integer :bank_id

      t.timestamps
    end
  end
end
