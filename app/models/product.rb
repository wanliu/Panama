class Product
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Graphical::Display

  attr_accessor :uploader_secure_token
  
  field :title, type: String
  field :name, type: String
  field :price, type: BigDecimal
  field :summary, type: String

  mount_uploader :preview, ImageUploader

  define_graphical_attr :photos, :handler => :default_image, :allow => [:test]  

  configrue_graphical :test => "160x120"
  
  belongs_to :shop
  belongs_to :category

  validates :title, presence: true
  validates :name, presence: true
  validates :price, presence: true
  validates :price, numericality: true

  validates_presence_of :category
  validates_presence_of :shop

  def default_image
      preview
  end
end
