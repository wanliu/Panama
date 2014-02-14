class PriceOption < ActiveRecord::Base
  belongs_to :property
  belongs_to :optionable, :polymorphic => true
  attr_accessible :id, :name, :title, :property_id, :property, :optionable
  #
  #
  def title
    @title || property.title unless property.nil?
  end

  def name
    @name || property.name unless property.nil?
  end
end
