class CircleSetting < ActiveRecord::Base
  attr_accessible :limit_city, :limit_join, :circle

  has_one :circle, dependent: :destroy, class_name: "CircleSetting", foreign_key: "setting_id"

end
