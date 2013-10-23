class RegionPicture < ActiveRecord::Base
  include Graphical::Display
  attr_accessible :attachment_id, :region_id

  belongs_to :region
  belongs_to :attachment, :class_name => "Attachment"

  define_graphical_attr :photos, :handler => :default_photo

  def default_photo
    attachment ? attachment.file : Attachment.new.file    
  end
end