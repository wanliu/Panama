class CreateShopGroups < ActiveRecord::Migration
  def change
    create_table :shop_groups do |t|
      t.integer :shop_id
      t.string :name

      t.timestamps
    end
  end
end
