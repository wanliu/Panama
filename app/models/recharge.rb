# encoding: utf-8
class Recharge < ActiveRecord::Base
  attr_accessible :money, :payer, :state, :user

  belongs_to :user

  validates :money, :numericality => {:greater_than_or_equal_to => 0.01}, :presence => true
  validates :user, :presence => true

  acts_as_status :payer, [:kuaiqian]

  after_initialize do 
    self.state = false if state.nil?
  end

  after_save do 
    generate_transfer
  end

  def self.kuaiqian(options = {})
    create(options.merge(:payer => :kuaiqian))
  end

  def successfully
    self.update_attribute(:state, true)
  end

  def generate_transfer
    if changed.include?("state")      
      user.recharge(money, 
        :source => self,
        :decription => "充值") if state
    end
  end

  def payer_title
    I18n.t("recharge.payer.#{payer.name}")
  end

  def state_title
    state ? "成功" : "失败"
  end
end
