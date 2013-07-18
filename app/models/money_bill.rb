#encoding: utf-8
#资金帐目
class MoneyBill < ActiveRecord::Base
  attr_accessible :decription, :money, :owner, :user

  belongs_to :owner, :polymorphic => true
  belongs_to :user

  validates :user, :presence => true
  validates :owner, :presence => true
  validates :serial_number, :presence => true

  before_validation(:on => :create) do
    self.serial_number = Time.now.strftime("%Y%m%d%H%M%S%4N")
  end

  after_create :calculate_money

  def calculate_money
    u = user.reload
    u.money = u.money + money
    u.save
  end

  def owner_name
    I18n.t("activerecord.models.#{owner_type.underscore}")
  end

  def owner_value
    if owner.present?
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
    else
      "未知"
    end
  end
end
