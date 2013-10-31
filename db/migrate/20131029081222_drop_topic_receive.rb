class DropTopicReceive < ActiveRecord::Migration
  def change
  	drop_table "topic_receives"
  end

end
