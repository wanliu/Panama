class ActivitiesAttachments < ActiveRecord::Base
  attr_accessible :activity_id, :attachment_id, :integer, :number
end
