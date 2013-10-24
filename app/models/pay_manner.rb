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

  def online_payment?
  	code == "online_payment"
  end

  def bank_transfer?
  	code == "bank_transfer"
  end

  def cash_on_delivery?
  	code == "cash_on_delivery"
  end

  def self.online_payment
    find_by(:code => :online_payment)
  end
end
