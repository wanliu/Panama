class PriceOption < ActiveRecord::Base
  belongs_to :property
  attr_accessible :id, :name, :title, :property_id
  #
  #
  def title
    @title || property.title
  end

  def name
    @name || property.name
  end
end
