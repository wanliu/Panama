class Product
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :price, type: BigDecimal
  field :summary, type: String

  has_many :photos
end
