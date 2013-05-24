class Activity < ActiveRecord::Base

  attr_accessible :url, :product_id, :start_time, :end_time, :price

  belongs_to :product
  belongs_to :author, :class_name => "User"

  has_many :activity_rules

  validates_associated :product

  validates :price, :presence => true

end
