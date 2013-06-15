class AddSomeThingToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :description, :string, :limit => 255
    add_column :activities, :product_id, :integer, :limit => 11
    add_column :activities, :price, :decimal, :precision => 10, :scale => 2
    add_column :activities, :start_time, :datetime
    add_column :activities, :end_time, :datetime
    add_column :activities, :author_id, :integer, :limit => 11
    add_column :activities, :limit_count, :integer, :limit => 5
  end
end
