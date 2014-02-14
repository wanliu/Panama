class AddTopicCategoryIdToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :topic_category_id, :integer
  end
end
