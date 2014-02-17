class AddContentableToContent < ActiveRecord::Migration
  def change
    add_column :contents, :contentable_id, :integer
    add_column :contents, :contentable_type, :string
  end
end
