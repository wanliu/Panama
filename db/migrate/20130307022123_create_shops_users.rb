class CreateShopsUsers < ActiveRecord::Migration
  def change
    create_table :shops_users do |t|
      t.integer :shop_id
      t.integer :user_id

      t.timestamps
    end
  end
end
