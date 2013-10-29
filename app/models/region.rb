class Region < ActiveRecord::Base
  attr_accessible :name, :region_cities
  has_many :region_cities, dependent: :destroy

  has_and_belongs_to_many :attachments, :class_name => "Attachment"  

  def city_names
  	region_cities.map do |rc|
  		City.find(rc.city_id).try(:name)
  	end
  end

end
