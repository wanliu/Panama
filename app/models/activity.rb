class Activity < ActiveRecord::Base

  attr_accessible :url

  has_many :activity_rules
end
