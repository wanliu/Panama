class StyleItem < ActiveRecord::Base
  attr_accessible :title, :value, :checked, :style_group_id

  belongs_to :style_group

  has_many :style_pairs
  has_many :sub_products, through: :style_pairs

  validates :title, uniqueness: { scope: :style_group_id,
  	                              message: "this tltle: %{value} has been taken alreadly in this product's styles"}

  validates :value, uniqueness: { scope: :style_group_id,
  	                              message: "this value: %{value} has been taken alreadly in this product's styles"}

  validates :style_group_id, presence: true

end
