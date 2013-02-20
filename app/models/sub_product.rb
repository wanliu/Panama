class SubProduct < ActiveRecord::Base
  attr_accessible :quantity, :price

  has_many :style_pairs
  has_many :items, through: :style_pairs, source: :style_item
  belongs_to :product

  def styles
  	result = { quantity: quantity, price: price }
  	items.each do |item|
  		result[item.style_group.name.singularize.to_sym] = item.title
  	end
  	result
  end
end
