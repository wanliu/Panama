#encoding: utf-8
# describe: 帖子接收者
# attributes:
#   topic_id: 帖子
#   user_id: 接收者(用户)
class TopicReceive < ActiveRecord::Base
  attr_accessible :user_id, :topic_id

  belongs_to :topic
  belongs_to :user

  validates :topic_id, presence: true
  validates :user_id, presence: true

  validates_presence_of :user
  validates_presence_of :topic
end
