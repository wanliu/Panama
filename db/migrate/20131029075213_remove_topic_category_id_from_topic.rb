class RemoveTopicCategoryIdFromTopic < ActiveRecord::Migration
  def up
    remove_column :topics, :topic_category_id
  end

  def down
    add_column :topics, :topic_category_id, :integer
  end
end
