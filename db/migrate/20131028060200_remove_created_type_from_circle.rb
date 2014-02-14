class RemoveCreatedTypeFromCircle < ActiveRecord::Migration
  def up
    remove_column :circles, :created_type
  end

  def down
    add_column :circles, :created_type, :string
  end
end
