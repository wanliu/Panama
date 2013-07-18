class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.string :type
      t.references :user
      t.timestamps
    end
  end
end
