class Style
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  has_many :colours
  has_many :sizes

  belongs_to :product, :dependent => :destroy

  validates_presence_of :product
end