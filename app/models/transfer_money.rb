#encoding: utf-8
# 资金帐单
class TransferMoney < ActiveRecord::Base
  attr_accessible :decription, :from_id, :money, :owner_id, :owner_type, :to_id

  belongs :to, :class_name => "User"
  belongs :from, :class_name => "User"
  belongs :owner, :polymorphic => true

  validates [:to, :from], :presence => true

  before_validation :on => :create do
  	self.number = Time.now.strftime("%Y%m%d%H%M%S%4N")
  end
end
