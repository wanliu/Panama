class PriceOption < ActiveRecord::Base
  belongs_to :property
  # attr_accessible :title, :body
  #
  #
  def title
    @title || property.title
  end

  def name
    @name || property.name
  end
end
