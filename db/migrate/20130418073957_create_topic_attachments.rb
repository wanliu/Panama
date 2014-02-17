class CreateTopicAttachments < ActiveRecord::Migration
  def change
    create_table :topic_attachments do |t|
      t.integer :topic_id
      t.integer :attachment_id

      t.timestamps
    end
  end
end
