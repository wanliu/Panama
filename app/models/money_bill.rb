#encoding: utf-8
# 余额帐单
#
# state: 是否可以使用(true 可用, false 不可用)
class MoneyBill < ActiveRecord::Base
  attr_accessible :money, :user, :state, :transfer

  belongs_to :user
  belongs_to :transfer, :class_name => "TransferMoney"

  validates :user, :presence => true
  validates :serial_number, :presence => true
  validates :money, :presence => true, :numericality => true

  before_validation(:on => :create) do
    self.serial_number = Time.now.strftime("%Y%m%d%H%M%S%4N")
    self.state = true if state.nil?
  end

  after_create :calculate_money

  after_update do 
    calculate_money if changed.include?("state")
  end

  def calculate_money
    if state
      user.money = user.money + money
      user.save
    end
  end

  def active_money
    self.update_attributes(:state => true)
  end

  def self.unavailable
    self.where(:state => false).sum(:money)
  end

  def self.available
    self.where(:state => true).sum(:money)
  end

end
