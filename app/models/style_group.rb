class StyleGroup < ActiveRecord::Base
  attr_accessible :name

  belongs_to :product
  has_many :items, class_name: 'StyleItem', dependent: :destroy
end
