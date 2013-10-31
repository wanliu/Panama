class Setting < ActiveRecord::Base
  attr_accessible :target_id, :target_type, :value, :var

  validates_presence_of :var, :value
  validates_uniqueness_of :var, :scope => :target_type
end
