class RemovePathToFileEntity < ActiveRecord::Migration
  def up
    remove_column :file_entities, :path
  end

  def down
    add_column :file_entities, :path, :string
  end
end
