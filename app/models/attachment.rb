class Attachment
  include Mongoid::Document

  attr_accessible :description, :file, :filename, :file_filename
  attr_accessor :uploader_secure_token

  field :filename, :type => String

  belongs_to :attachable, :polymorphic => true

  mount_uploader :file, ImageUploader

end
