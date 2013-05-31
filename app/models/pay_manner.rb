#付款方式
class PayManner < ActiveRecord::Base
  scope :avaliable, where(:state => true)
  scope :invalid, where(:state => false)

  attr_accessible :description, :name

  validates :name, :presence => true, :uniqueness => true
end
