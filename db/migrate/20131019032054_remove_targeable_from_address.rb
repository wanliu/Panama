class RemoveTargeableFromAddress < ActiveRecord::Migration
  def up
    remove_column :addresses, :targeable_id
    remove_column :addresses, :targeable_type
  end

  def down
    add_column :addresses, :targeable_type, :string
    add_column :addresses, :targeable_id, :integer
  end
end
