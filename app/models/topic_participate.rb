#encoding: utf-8
class TopicParticipate < ActiveRecord::Base
  attr_accessible :topic_id, :user_id

  belongs_to :topic
  belongs_to :user

  validates :user, :presence => true
  validates :topic, :presence => true

  validate :valid_unqi_user?

  after_create do
    update_topic_participate
  end

  private
  def valid_unqi_user?
    if TopicParticipate.exists?(["topic_id=? and user_id=? and id<>?",
      topic_id, user_id, id.to_s])
      errors.add(:user_id, "该用户已经加入!")
    end
  end

  def update_topic_participate
    topic.update_participate
  end
end
