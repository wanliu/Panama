# encoding : utf-8
class RegionCity < ActiveRecord::Base
  attr_accessible :city_id, :region_id

  validates :region_id, presence: true
  validates :city_id, presence: true

  validate :validate_city?

  belongs_to :region
  belongs_to :city

  def validate_city?
  	if RegionCity.exists?(["city_id=?", city_id])
      errors.add(:city_id, "该城市已经被划分为其他区域了!")
    end
  end

  def self.location_region(city_id)
    find_by(:city_id => city_id).try(:region)
  end
end