# encoding: utf-8
# 提现
# arrive_mode: 到帐方式
class WithdrawMoney < ActiveRecord::Base
  attr_accessible :arrive_mode, :bank_id, :money, :user
  scope :untreated, ->{ where(:state => 0) }
  scope :completed, ->{ where(:state => _get_state_val(:state, :succeed)) }
  scope :failer, ->{ where(:state => _get_state_val(:state, :failer)) }

  belongs_to :bank, :class_name => "UserBank"
  belongs_to :user
  has_one :transfer_money, :as => :owner  

  validates :bank, :user, :presence => true
  validates :money, :numericality => { :greater_than_or_equal_to => 0.01 }

  after_initialize do
    self.arrive_mode = :morrow if arrive_mode == :invalid
    self.money = 0 if money.nil?
  end

  after_create do 
    begin      
      user.transfer_moneys.pay_out!(
        :money => money,
        :source => self,
        :decription => "提现"
      )      
    rescue Exception => e
      raise e
    end
  end

  after_update do 
    failer_rollback_money
  end

  validate :valid_arrive_mode?, :bank_owner_user?

  validate :valid_user_money?, :on => :create

  acts_as_status :state, [:succeed, :failer]

  #morrow:次日 intime:(2小时到帐户)
  acts_as_status :arrive_mode, [:morrow, :intime]

  private 
  def valid_arrive_mode?
    errors.add(:arrive_mode, "到帐时间不正确!") if arrive_mode == :invalid
  end

  def bank_owner_user?
    errors.add(:bank, "银行卡不属于自己") if bank.nil? || bank.user != user
  end 

  def valid_user_money?
    errors.add(:money, "金额大于你的余额!") if user.nil? || user.money < money
  end

  def failer_rollback_money
    if changed.include?("state")
      if state == :failer
        user.transfer_moneys.income!(
          :money => money,
          :source => self,
          :decription => "提现失败还原金额"
        )
      end
    end
  end
end
