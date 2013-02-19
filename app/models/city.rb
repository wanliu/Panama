class City < ActiveRecord::Base
  attr_accessible :name

  has_one :address
end
