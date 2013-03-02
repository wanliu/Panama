class StyleItem < ActiveRecord::Base
  attr_accessible :title, :value, :checked, :style_group_id

  belongs_to :style_group

  has_many :style_pairs
  has_many :sub_products, through: :style_pairs

  validates :title, presence: true
  validates :title, uniqueness: { scope: :style_group_id,
  	                              message: "this tltle: %{value} exsits under the same stylegroup" }

  validates :value, presence: true
  validates :value, uniqueness: { scope: :style_group_id,
  	                              message: "this value: %{value} exsits under the same stylegroup" }

  validates :style_group_id, presence: true

  scope :checked_items, where("checked", true)

end
