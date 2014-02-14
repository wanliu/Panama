class CreateProductComments < ActiveRecord::Migration
  def change
    create_table :product_comments do |t|
      t.integer :product_item_id
      t.integer :shop_id
      t.integer :user_id
      t.integer :star_product
      t.integer :star_service
      t.integer :star_logistics

      t.timestamps
    end
  end
end
