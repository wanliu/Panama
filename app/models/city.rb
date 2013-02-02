class City
	include Mongoid::Document
	include Mongoid::Tree

	belongs_to :address
	
	field :name
	field :city_id
end