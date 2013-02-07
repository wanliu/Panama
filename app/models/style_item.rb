class StyleItem
  include Mongoid::Document

  field :title, type: String
  field :value, type: String
  field :checked, type: Boolean, default: false

  belongs_to :style_group
end