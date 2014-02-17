class AddCategoryIdAndCircleIdToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :category_id, :integer
    add_column :topics, :circle_id, :integer
  end
end
