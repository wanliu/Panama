class RegionCity < ActiveRecord::Base
  attr_accessible :city_id, :region_id

  validates :city_id, uniqueness: true

  belongs_to :region
  belongs_to :city
end