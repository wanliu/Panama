class Colour
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :rgb, type: String
  field :name, type: String

  belongs_to :style, :dependent => :destroy

  validates_presence_of :style
end