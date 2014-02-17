class CircleSetting < ActiveRecord::Base
  attr_accessible :limit_city, :limit_join, :circle

  has_one :circle, dependent: :destroy, foreign_key: "setting_id"
  
end
