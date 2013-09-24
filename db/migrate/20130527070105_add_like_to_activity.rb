class AddLikeToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :like, :integer, :limit => 11, :default => 0
    add_column :activities, :participate, :integer, :limit => 11, :default => 0
  end
end
