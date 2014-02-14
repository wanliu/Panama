class Mongodb::City
	include Mongoid::Document
	include Mongoid::Tree

	has_one :address

	field :name
end