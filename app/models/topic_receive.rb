#encoding: utf-8
# describe: 帖子接收者
# attributes:
#   topic_id: 帖子
#   receive_id: 接收者(用户或者商店或者圈子)
class TopicReceive < ActiveRecord::Base
  attr_accessible :receive_id, :topic_id, :receive_type, :receive

  belongs_to :topic
  belongs_to :receive, :polymorphic => true

  validates :topic_id, presence: true
  validates :receive_id, presence: true
  validates :receive_type, presence: true

  validates_presence_of :receive
  validates_presence_of :topic

  validate :valid_receive_type?

  def self.creates(receives, topic_id = nil)
    options = topic_id.nil? ? {} : {topic_id: topic_id}
    receives.each do |receive|
      create(options.merge(receive: receive))
    end
  end

  def self.user_related(user_id)
    where(receive_type: "User", receive_id: user_id)
  end

  def self.shop_related(shop_id)
    where(receive_type: "Shop", receive_id: shop_id)
  end

  def self.circle_related(circle_id)
    where(receive_type: "Circle", receive_id: circle_id)
  end

  def self.user(user, topic_id = nil)
    _create("User", user, topic_id)
  end

  def self.shop(shop, topic_id = nil)
    _create("Shop", shop, topic_id)
  end

  def self.circle(circle, topic_id = nil)
    _create("Circle", circle, topic_id)
  end

  class << self
    private
    def _create(receive_type, model, topic_id)
      options = {receive_id: model, receive_type: receive_type}
      options[:receive_id] = model.id if model.class.name == receive_type
      options[:topic] = topic_id unless topic_id.nil?
      create(options)
    end
  end

  def valid_receive_type?
    if !receive.is_a?(User) && !receive.is_a?(Shop) && !receive.is_a?(Circle)
      errors.add(:receive_type, "不是通知类型！")
    end
  end

end
