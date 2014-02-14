class CreateFileEntities < ActiveRecord::Migration
  def change
    create_table :file_entities do |t|
      t.string :name
      t.string :stat
      t.integer :size
      t.text :data
      t.string :path

      t.timestamps
    end
  end
end
