class RegionCity < ActiveRecord::Base
  attr_accessible :city_id, :region_id

  belongs_to :region
  belongs_to :city
end