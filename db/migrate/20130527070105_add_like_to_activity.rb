class AddLikeToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :like, :integer, :limit => 11
    add_column :activities, :participate, :integer, :limit => 11
  end
end
