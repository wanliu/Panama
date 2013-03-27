#encoding: utf-8
# describe: 帖子接收者
# attributes:
#   topic_id: 帖子
#   receive_id: 接收者(用户或者商店)
class TopicReceive < ActiveRecord::Base
  attr_accessible :receive_id, :topic_id, :receive_type

  belongs_to :topic
  belongs_to :receive, :polymorphic => true

  validates :topic_id, presence: true
  validates :receive_id, presence: true
  validates :receive_type, presence: true

  validates_presence_of :receive
  validates_presence_of :topic

  def self.user(user, topic_id = nil)
    options = {receive_id: user, receive_type: "User"}
    options[:receive_id] = user.id if user.is_a?(User)
    options[:topic] = topic_id unless topic_id.nil?
    create(options)
  end

  def self.shop(shop, topic_id = nil)
    options = {receive_id: shop, receive_type: "Shop"}
    options[:receive_id] = shop.id if shop.is_a?(Shop)
    options[:topic] = topic_id unless topic_id.nil?
    create(options)
  end
end
