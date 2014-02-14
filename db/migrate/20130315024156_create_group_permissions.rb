class CreateGroupPermissions < ActiveRecord::Migration
  def change
    create_table :group_permissions do |t|
      t.integer :group_id
      t.integer :permission_id

      t.timestamps
    end
  end
end
