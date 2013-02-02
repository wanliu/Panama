class Size
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field: name

  belongs_to :style, :dependent => :destroy

  validates_presence_of :style
end