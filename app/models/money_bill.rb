#encoding: utf-8
# 余额帐单
#
# state: 是否可以使用(true 可用, false 不可用)
class MoneyBill < ActiveRecord::Base
  attr_accessible :money, :user, :state

  belongs_to :user
  has_one :transfer, :class_name => "TransferMoney"

  validates :user, :presence => true
  validates :serial_number, :presence => true
  validates :money, :presence => true, :numericality => true

  before_validation(:on => :create) do
    self.serial_number = Time.now.strftime("%Y%m%d%H%M%S%4N")
  end

  after_create :calculate_money

  def calculate_money
    user.money = user.money + money
    user.save
  end

  def owner_name
    I18n.t("activerecord.models.#{owner_type.underscore}")
  end

  def owner_value
    case owner_type
    when "OrderTransaction"
      owner.number
    when "Bank"
      owner.name
    when "OrderRefund"
      owner.id
    else
      "未知"
    end
  end

  def self.create!(opts)
    options = opts.symbolize_keys

    money = options.delete(:state) || true
    that = super(:money => options.money, :state => money)
    that.save!
    that.transfer.create options
    that
  end
end
