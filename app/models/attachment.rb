class Attachment
  include Mongoid::Document

  attr_accessible :description
  attr_accessor :uploader_secure_token

  field :attachable

  # belongs_to :attachable, :polymorphic => true

  mount_uploader :attachable, ImageUploader
end
