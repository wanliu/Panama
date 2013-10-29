class AddAttachmentIdToCircle < ActiveRecord::Migration
  def change
    add_column :circles, :attachment_id, :integer
  end
end
