class ActivityRule < ActiveRecord::Base
  attr_accessible :name, :value, :value_type, :nvalue, :dvalue, :dtvalue, :fvalue

  validates :dvalue, :numericality => { :greater_than => 0 }

  belongs_to :activity
end