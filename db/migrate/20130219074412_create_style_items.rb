class CreateStyleItems < ActiveRecord::Migration
  def change
    create_table :style_items do |t|
      t.string :title
      t.string :value
      t.boolean :checked, default: false
      t.references :style_group, unll: false

      t.timestamps
    end
  end
end
