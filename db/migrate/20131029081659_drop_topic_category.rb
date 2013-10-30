class DropTopicCategory < ActiveRecord::Migration
  def change
  	drop_table "topic_categories"
  end
end
