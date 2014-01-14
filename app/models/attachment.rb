class Attachment < ActiveRecord::Base
  include Graphical::Display

  attr_accessible :description, :file, :filename, :file_filename
  attr_accessor :uploader_secure_token

  # belongs_to :attachable, :polymorphic => true
  has_many :default_product, :class_name => "Product"
  has_and_belongs_to_many :products, :class_name => "Product"
  has_and_belongs_to_many :activities, :class_name => "Activity"

  mount_uploader :file, ImageUploader

  define_graphical_attr :photos, :handler => :default_photo

  def default_photo
    file
  end

  def as_json(*args)
    options = args.extract_options!
    _attributes = super *args
    _attributes[:photos] = photos.attributes
    _attributes[:url] = file.url(options[:version_name])
    _attributes
  end

end
