class Attachment
  include Mongoid::Document

  attr_accessible :description, :file

  belongs_to :attachable, :polymorphic => true

  mount_uploader :file, ImageUploader
end
