class Service < ActiveRecord::Base

  attr_accessible :name, :service_type

  has_and_belongs_to_many :users
  has_one :user_checking

  validates :service_type, inclusion: { in: %w(buyer seller),
    message: "%{value} is not a valid type" }

  def self.buyer
  	find_by(:service_type => 'buyer')
  end

  def self.seller
  	find_by(:service_type => "seller")
  end
end
