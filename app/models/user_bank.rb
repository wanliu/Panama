# encoding: utf-8
# 银行卡管理
class UserBank < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :bank_id, :code, :name, :state, :user

  belongs_to :bank
  belongs_to :user

  validates :code, :presence => true, format: { with: /^\d{19}$/, message: "请确定银行卡号真实有效，只能是19位数字" }

  validates :bank, :user, :name, :presence => true
  validates :name, format: { with: /^[\u4e00-\u9fa5]{2,}$/, message: "请确定姓名真实有效，不能有空格" }

  delegate :name, :code, :to => :bank, :prefix => :bank

  validate :valid_bank_uniq?

  def code_title
    code.gsub(/(.{4})/){ "#{$1} " }
  end

  private 
  def valid_bank_uniq?
    if UserBank.exists?([
      "bank_id=? and user_id=? and id<>?", bank_id, user_id, id.to_s])
      errors.add(:bank_id, "已经存在该银行了！")
    end
  end 
end
