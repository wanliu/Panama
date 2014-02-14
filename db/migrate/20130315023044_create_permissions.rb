class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :resource
      t.string :ability

      t.timestamps
    end
  end
end
