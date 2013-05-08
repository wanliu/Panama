#encoding: utf-8
#describe: 接收订单聊天信息
#  message: 信息
#  order_transaction_id: 订单关系
#  send_user_id: 发送人
#  state: 状态 (false未读信息 true读取信息)
class ReceiveOrderMessage < ActiveRecord::Base
  attr_accessible :message, :order_transaction, :send_user

  validates :message, :presence => true

  validates_presence_of :order_transaction
  validates_presence_of :send_user

  belongs_to :order_transaction
  belongs_to :send_user
end
