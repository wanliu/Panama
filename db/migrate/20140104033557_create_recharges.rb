class CreateRecharges < ActiveRecord::Migration
  def change
    create_table :recharges do |t|
      t.integer :user_id
      t.decimal :money, :precision => 10, :scale => 2
      t.integer :payer
      t.boolean :state, :default => false

      t.timestamps
    end
  end
end
