# encoding: utf-8
# 银行卡管理
class UserBank < ActiveRecord::Base
  attr_accessible :bank_id, :code, :name, :state, :user

  belongs_to :bank
  belongs_to :user

  validates :bank, :user, :code, :name, :presence => true

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
