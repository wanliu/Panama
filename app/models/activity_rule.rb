class ActivityRule < ActiveRecord::Base
  attr_accessible :name, :value, :value_type, :nvalue, :dvalue, :dtvalue, :fvalue

  validates :dvalue, :numericality => { :greater_than => 0 }

  belongs_to :activity

  def type_val
    self.send(value_type)
  end
end