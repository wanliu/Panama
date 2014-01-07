# encoding: utf-8
# 提现
# arrive_mode: 到帐方式
class WithdrawMoney < ActiveRecord::Base
  attr_accessible :arrive_mode, :bank_id, :money, :state, :user_id

  belongs_to :bank, :class_name => "UserBank"
  belongs_to :user

  validates :bank, :user, :presence => true
  validates :money, :numericality => { :greater_than_or_equal_to => 0.01 }

  acts_as_status :state, [:succeed, :failer]
end
