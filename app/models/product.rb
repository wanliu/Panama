class Product
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  attr_accessor :uploader_secure_token
  
  field :name, type: String
  field :price, type: BigDecimal
  field :summary, type: String

  mount_uploader :preview, ImageUploader

  has_many :attachments, :as => :attachable

  accepts_nested_attributes_for :attachments

  has_many :photos
  belongs_to :shop
  belongs_to :category

  validates :name, presence: true
  validates :price, presence: true
  validates :price, numericality: true

  validates_presence_of :category
  validates_presence_of :shop
end
