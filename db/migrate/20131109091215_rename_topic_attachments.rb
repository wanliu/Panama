class RenameTopicAttachments < ActiveRecord::Migration
  def change
  	rename_table :topic_attachments, :attachments_topics
  end
end
