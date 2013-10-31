class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :var
      t.string :value
      t.integer :target_id
      t.string :target_type

      t.timestamps
    end
  end
end
