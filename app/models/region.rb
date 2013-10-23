class Region < ActiveRecord::Base
  attr_accessible :name, :region_cities
  has_many :region_cities
  has_many :region_pictures
end
