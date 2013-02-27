class CreateStylePairs < ActiveRecord::Migration
  def change
    create_table :style_pairs do |t|
    	t.integer :style_item_id, null: false
      t.integer :sub_product_id, null: false
    end
  end
end
