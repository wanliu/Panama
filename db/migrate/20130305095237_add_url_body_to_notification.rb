class AddUrlBodyToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :url, :string
    add_column :notifications, :body, :text
  end
end
