class PriceOption < ActiveRecord::Base
  belongs_to :property
  attr_accessible :id, :name, :title, :property_id, :property
  #
  #
  def title
    @title || property.title unless property.nil?
  end

  def name
    @name || property.name unless property.nil?
  end
end
