class SubProduct < ActiveRecord::Base
  attr_accessible :quantity, :price

  belongs_to :product

  has_many :style_pairs
  has_many :items, through: :style_pairs, source: :style_item

  validates :product_id, presence: true
  validates :quantity, presence: true, numericality: true
  validates :price, presence: true, numericality: true

  def styles
  	result = { quantity: quantity, price: price }
  	items.each do |item|
  		result[item.style_group.name.singularize.to_sym] = item.title
  	end
  	result
  end
end
