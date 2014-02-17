class AddAncestryToCity < ActiveRecord::Migration
  def change
    add_column :cities, :ancestry, :string
  end
end
