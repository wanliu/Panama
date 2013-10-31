class RenameRegionPictureToAttachmentRegion < ActiveRecord::Migration
  def change
  	rename_table :region_pictures, :attachments_regions
  end
end
