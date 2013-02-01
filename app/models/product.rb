class Product
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Graphical::Display

  attr_accessor :uploader_secure_token
  
  field :name, type: String
  field :price, type: BigDecimal
  field :summary, type: String

  mount_uploader :preview, ImageUploader

  has_many :attachments, :as => :attachable

  accepts_nested_attributes_for :attachments,
                                :reject_if => proc { |att| att['file_filename'].blank? }, 
                                :allow_destroy => true

  define_graphical_attr :photos, :handler => :default_image  

  belongs_to :shop
  belongs_to :category

  # validates :title, presence: true
  validates :name, presence: true
  validates :price, presence: true
  validates :price, numericality: true

  validates_presence_of :category
  validates_presence_of :shop

  def default_image
      preview
  end
end
