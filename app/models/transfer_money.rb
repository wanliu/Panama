# encoding: utf-8
# 资金帐单
class TransferMoney < ActiveRecord::Base
  attr_accessible :decription, :user, :money, :owner, :pay_type, :source
  
  belongs_to :user
  belongs_to :owner, :polymorphic => true
  belongs_to :source, :polymorphic => true

  has_one :money_bill, :foreign_key => "transfer_id"

  acts_as_status :pay_type, [:account, :kuaiqian, :bank_transfer]

  validates :user, :owner, :source, :presence => true
  validates :number, :presence => true, :uniqueness => true

  validate :valid_pay_type?, :valid_money?

  before_validation :on => :create do
    self.number = Time.now.strftime("%Y%m%d%H%M%S%4N")
  end

  after_destroy do 
    money_bill.destroy if money_bill.present?
  end

  def owner_name
    I18n.t("activerecord.models.#{owner_type.underscore}")
  end

  def source_value
    case source_type
    when "User"
      source.login
    when "Bank"        
      source.name
    when "Recharge"
      source.payer_title
    when "WithdrawMoney"
      source.bank.try(:bank_name)
    else
      "未知"
    end
  end

  def pay_type_title
    I18n.t("transfer_money.pay_type.#{pay_type.name}")
  end

  #收入到帐多是到平台账户余额
  def active_money
    money_bill.active_money if pay_type == :account
  end

  def create_money_bill(options = {})
    MoneyBill.create!(options.merge({
      :transfer => self,
      :user => user,
      :money => money}))
  end

  class << self 

    # 支出
    # options{
    #   money => 金额
    #   source => 给某个对象或者用户
    #   owner => 所属 为空就和source一样
    #   decription => 描述
    #   pay_type => 支付方式 默认 account
    # }
    def pay_out!(options = {})
      options[:money] = -options[:money]  
      options[:owner] = options[:owner] || options[:source]
      options[:pay_type] = :account unless options.key?(:pay_type)

      that = create!(options)              
      that.create_money_bill if that.pay_type == :account
      that
    end

    # 收入
    # options {
    #   state => 对方是否及时到帐户 
    #   money => 金额
    #   source => 给某个对象或者用户
    #   owner => 所属 为空就和source一样
    #   decription => 描述
    #   pay_type => 支付方式 默认 account
    # }
    def income!(options = {})           
      state = options.delete(:state)             
      options[:owner] = options[:owner] || options[:source]
      that = create!(options.merge(:pay_type => :account))
      that.create_money_bill(:state => state)
      that
    end
  end

  private 
  def valid_pay_type?
    errors.add(:pay_type, "支付类型无效！") if pay_type == :invalid
  end

  def valid_money?
    if money < 0
      if user.valid_money?(money.abs) && pay_type == :account
        errors.add(:user_id, "余额不足!请充值")
      end
    end
  end
end
