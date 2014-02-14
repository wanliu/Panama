class AttachmentsRegions < ActiveRecord::Base
  attr_accessible :attachment_id, :region_id
  belongs_to :region
end