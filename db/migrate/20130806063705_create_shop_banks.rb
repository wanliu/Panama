class CreateShopBanks < ActiveRecord::Migration
  def change
    create_table :shop_banks do |t|
      t.integer :shop_id
      t.integer :bank_id
      t.string :code
      t.string :name
      t.boolean :state

      t.timestamps
    end
  end
end
