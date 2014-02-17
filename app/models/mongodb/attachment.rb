class Mongodb::Attachment
  include Mongoid::Document

  attr_accessible :description, :file, :filename, :file_filename
  attr_accessor :uploader_secure_token

  field :filename, :type => String

  belongs_to :attachable, :polymorphic => true
  has_many :default_product, :class_name => "Product", :inverse_of => :default_attachment  
  has_and_belongs_to_many :products, :class_name => "Product", :inverse_of => :attachments
  
  mount_uploader :file, ImageUploader

  def get_attributes(version_name = nil)
  	_attributes = attributes
  	_attributes[:url] = file.url(version_name)
    _attributes[:id] = id    
  	_attributes
  end

  # validates :file_filename, :length => { :minimum => 2 }
end
