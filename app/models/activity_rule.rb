class ActivityRule < ActiveRecord::Base
  attr_accessible :name, :value, :value_type, :nvalue, :dvalue, :dtvalue, :fvalue

  validates :dvalue, :numericality => { :greater_than => 0 }

  belongs_to :activity

  def type_val
    self.send(value_type)
  end

  def self.focus_price(participate)
		rule = order("value desc").find_by("value<=#{participate}")
		rule = min_level if rule.nil?
		rule.type_val
  end

  def self.min_level
  	order("value asc").limit(1)[0]
  end
end