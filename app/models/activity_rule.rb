class ActivityRule < ActiveRecord::Base
  attr_accessible :name, :value_type, :nvalue, :dvalue, :dtvalue, :fvalue, :value

  belongs_to :activity
end