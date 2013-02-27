class CreateProductComments < ActiveRecord::Migration
  def change
    create_table :product_comments do |t|
      t.string :content
      t.integer :user_id
      t.integer :product_id

      t.timestamps
    end
  end
end
