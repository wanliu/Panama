#encoding: utf-8
#describe: 社区贴子
#
#attributes:
#  content: 内容
#  owner: 所属者(商店与用户)
#  user_id: 发贴人
#  context_html: html内容
#  status: 状态
class Topic < ActiveRecord::Base
  attr_accessible :content, :owner_id, :owner_type, :user_id, :content_html, :status

  belongs_to :owner, :polymorphic => true
  belongs_to :user

  has_many :receives, class_name: "TopicReceive", dependent: :destroy

  validates :content, :presence => true

  validates_presence_of :user
  validates_presence_of :owner

  acts_as_status :status, [:puliceity, :external, :circle]

  def self.users(options = {})
    where(options.merge(:owner_type => "User"))
  end

  def self.shops(options = {})
    where(options.merge(:owner_type => "Shop"))
  end

  #获取某个商店的所有与它有关的贴
  def self.find_shop_or_friends(shop_id, circles)
    scope_related(shop_id, "Shop", circles)
  end

  #获取某个用户的所有与它有关的贴
  def self.find_user_or_friends(user_id, circles)
    scope_related(user_id, "User", circles)
  end

  def as_json(*args)
    attribute = super *args
    attribute["avatar_url"] = user.icon
    attribute["status"] = status.name
    attribute["login"] = user.login
    attribute["status_name"] = I18n.t("topic.#{status.name}")
    attribute
  end

  class << self

    private
    def scope_related(owner_id, owner_type, circles)
      #获取圈子的好友
      user_ids = circles.includes(:friends).map{|c| c.friends.map{|f| f.user_id} }.flatten

      #获取与我相关的贴,去除不是我好友的贴
      topic_ids = receive_topics(owner_type, owner_id)
      #获取圈子的发贴
      ctopic_ids = receive_topics("Circle", circles.map{|c| c.id})

      where("(owner_id=? and owner_type=? and status=1)" +
       " or (owner_id in (?) and owner_type ='User' and status=1)" +
       " or (id in (?) and owner_type='User' and owner_id in (?) )" +
       " or id in (?)",
        owner_id, owner_type, user_ids, topic_ids, user_ids, ctopic_ids
      )
    end

    def receive_topics(receive_type, receive_id)
      TopicReceive.where(receive_type: receive_type, receive_id: receive_id)
      .select("distinct topic_id").order('created_at desc').map{|t| t.topic_id}
    end

  end
end
