class CreateTopicCategories < ActiveRecord::Migration
  def change
    create_table :topic_categories do |t|
      t.string :name
      t.integer :shop_id

      t.timestamps
    end
  end
end
