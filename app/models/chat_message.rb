#encoding: utf-8
#describe: 聊天信息
#attributes
#  send_user_id: 发送人
#  receive_user_id: 接收人
#  content: 内容
class ChatMessage < ActiveRecord::Base
  attr_accessible :content, :receive_user_id, :send_user_id

  belongs_to :receive_user, class_name: "User"
  belongs_to :send_user, class_name: "User"

end
