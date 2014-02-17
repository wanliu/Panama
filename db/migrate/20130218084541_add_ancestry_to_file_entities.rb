class AddAncestryToFileEntities < ActiveRecord::Migration
  def change
    add_column :file_entities, :ancestry, :string
  end
end
