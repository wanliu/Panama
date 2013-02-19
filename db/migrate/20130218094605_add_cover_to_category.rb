class AddCoverToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :cover, :string
  end
end
