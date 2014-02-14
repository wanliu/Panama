class CreateActivitiesAttachments < ActiveRecord::Migration
  def change
    create_table :activities_attachments do |t|
      t.integer :attachment_id
      t.string :activity_id
      t.string :integer
      t.integer :number

      t.timestamps
    end
  end
end
