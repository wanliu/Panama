class AddParticipateToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :participate, :integer, :default => 0
  end
end
