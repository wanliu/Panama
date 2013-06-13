class ActivityRule < ActiveRecord::Base
  attr_accessible :name, :value_type, :nvalue, :dvalue, :dtvalue, :fvalue

  belongs_to :activity
end