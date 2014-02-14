class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name
      t.text :data
      t.integer :content_id

      t.timestamps
    end
  end
end
