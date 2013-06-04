#配送方式
class DeliveryManner < ActiveRecord::Base
  scope :avaliable, where(:state => true)
  scope :invalid, where(:state => false)

  attr_accessible :code, :name, :default_state

  validates :code, :presence => true, :uniqueness => true
  validates :name, :presence => true, :uniqueness => true

  def self.default
  	find_by(:default_state => true)
  end

  def local_delivery?
  	self.code == "local_delivery"
  end

  def express?
  	self.express == "express"
  end
end
