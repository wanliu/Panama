class Attachment
  include Mongoid::Document

  attr_accessible :description, :file
  attr_accessor :uploader_secure_token

  belongs_to :attachable, :polymorphic => true

  mount_uploader :file, ImageUploader
end
