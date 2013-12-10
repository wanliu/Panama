class RemoveTimestampFromActivityAttachment < ActiveRecord::Migration
  def up
    remove_timestamps(:activities_attachments)
  end

  def down
    add_timestamps(:activities_attachments)
  end
end
