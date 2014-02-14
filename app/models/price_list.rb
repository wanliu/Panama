class PriceList < ActiveRecord::Base
  attr_accessible :people_number, :price
  validates :people_number, :price , presence: true
  belongs_to :activity
end
