class Product
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :price, type: BigDecimal
  field :summary, type: String

  has_many :photos
  belongs_to :shop
  belongs_to :category

  validates :name, presence: true
  validates :price, presence: true
  validates :price, numericality: true
end
