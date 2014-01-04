class CreateTransferMoneys < ActiveRecord::Migration
  def change
    create_table :transfer_moneys do |t|
      t.integer :to_id
      t.integer :from_id
      t.string :owner_type
      t.integer :owner_id
      t.string :decription
      t.decimal :money, :precision => 10, :scale => 2
      t.string :number

      t.timestamps
    end
  end
end
