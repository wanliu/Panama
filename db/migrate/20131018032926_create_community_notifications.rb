class CreateCommunityNotifications < ActiveRecord::Migration
  def change
    create_table :community_notifications do |t|
      t.boolean :state, :default => false
      t.text :body

      t.timestamps
    end
  end
end
