class City < ActiveRecord::Base
  attr_accessible :name

  has_one :address
  has_one :delivery_addresses
  has_many :region_cities
  has_ancestry
end
