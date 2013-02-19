class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.string :name
      t.string :template
      t.boolean :lock

      t.timestamps
    end
  end
end
