class Service < ActiveRecord::Base
  attr_accessible :name, :type

  has_and_belongs_to_many :users

  validates :type, inclusion: { in: %w(buyer seller),
    message: "%{value} is not a valid type" }
end
