class CreateDirectTransactions < ActiveRecord::Migration
  def change
    create_table :direct_transactions do |t|
      t.integer :seller_id
      t.integer :buyer_id
      t.decimal :total

      t.timestamps
    end
  end
end
