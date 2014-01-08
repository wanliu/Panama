class CreateWithdrawMoneys < ActiveRecord::Migration
  def change
    create_table :withdraw_moneys do |t|
      t.decimal :money, :precision => 10, :scale => 2
      t.integer :bank_id
      t.integer :user_id
      t.integer :state, :default => 0
      t.integer :arrive_mode, :default => 0

      t.timestamps
    end
  end
end
