class Style
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :Colours, type: Array
  field :Sizes,   type: Array

  belongs_to :product

  validates_presence_of :product
end