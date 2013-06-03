#配送方式
class DeliveryManner < ActiveRecord::Base
  scope :avaliable, where(:state => true)
  scope :invalid, where(:state => false)

  attr_accessible :code, :name
end
