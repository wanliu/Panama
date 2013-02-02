class SubProduct
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :color, type: String
  field :size, type: String
  field :price, type: Float
  field :quantity, type: Float

  belongs_to :product

  validates :price, presence: true
  validates :price, numericality: true
  validates :quantity, presence: true
  validates :quantity, numericality: true

  validates_presence_of :product
end