#付款方式
class PayManner < ActiveRecord::Base
  scope :avaliable, where(:state => true)
  scope :invalid, where(:state => false)

  attr_accessible :description, :name, :code, :default_state

  validates :name, :presence => true, :uniqueness => true
  validates :code, :presence => true, :uniqueness => true

  def self.default
  	find_by(:default_state => true)
  end
end
