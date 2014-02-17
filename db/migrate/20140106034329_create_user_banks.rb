class CreateUserBanks < ActiveRecord::Migration
  def change
    create_table :user_banks do |t|
      t.integer :user_id
      t.integer :bank_id
      t.string :code
      t.string :name
      t.boolean :state, :default => true

      t.timestamps
    end
  end
end
