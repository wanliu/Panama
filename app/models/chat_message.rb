#encoding: utf-8
#describe: 聊天信息
#attributes
#  send_user_id: 发送人
#  receive_user_id: 接收人
#  content: 内容
class ChatMessage < ActiveRecord::Base
  scope :read, where(:read => true)
  scope :unread, where(:read => false)

  attr_accessible :content, :receive_user_id, :send_user_id

  belongs_to :receive_user, class_name: "User"
  belongs_to :send_user, class_name: "User"

  validates :receive_user_id, :presence => true
  validates :send_user_id, :presence => true
  validates :content, :presence => true

  validates_presence_of :receive_user
  validates_presence_of :send_user

  after_create :notic_receive_user
  before_create :join_contact_friend

  def self.all(send_user_id = nil, receive_user_id = nil)
    if !send_user_id.nil? && !receive_user_id.nil?
      where("(send_user_id=? and receive_user_id=?)
        or (send_user_id=? and receive_user_id=?)",
        send_user_id, receive_user_id, receive_user_id, send_user_id)
    else
      super
    end
  end

  def join_contact_friend
    send_user.contact_friends.join_friend(receive_user_id)
    receive_user.contact_friends.join_friend(send_user_id)
  end

  #变更状态
  def change_state
    self.update_attribute(:read, true)
    ChatMessage.notice_read_state(receive_user, send_user_id)
  end

  #通知接收人
  def notic_receive_user
    FayeClient.send("/chat/receive/#{receive_user.im_token}", as_json)
  end

  #通知接收人已经读取信息
  def self.notice_read_state(receive_user, send_user_id)
    FayeClient.send("/chat/change/message/#{receive_user.im_token}", send_user_id)
  end

  def as_json(*args)
    attra = super *args
    attra["receive_user"] = receive_user.as_json
    attra["send_user"] = send_user.as_json
    attra
  end
end