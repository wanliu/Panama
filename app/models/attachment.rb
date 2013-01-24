class Attachment
  include Mongoid::Document

  attr_accessible :description
  attr_accessor :uploader_secure_token

  field :attachable
  has_and_belongs_to_many :products, :class_name => "Product", :inverse_of => :attachments
  has_many :default_product ,:class_name => "Product", :inverse_of => :default_attachment
  # belongs_to :attachable, :polymorphic => true

  mount_uploader :attachable, ImageUploader

  def get_attributes(version_name = nil)
  	_attributes = attributes
  	_attributes[:url] = attachable.url(version_name)
  	_attributes
  end
end
