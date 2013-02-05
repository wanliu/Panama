class Style
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :colours, type: Array
  field :sizes,   type: Array

  belongs_to :product

  validates_presence_of :product
end