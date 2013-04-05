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
  attr_accessible :content, :owner_id, :owner_type, :user_id, :content_html, :status, :topic_category_id

  belongs_to :owner, :polymorphic => true
  belongs_to :user
  belongs_to :category, class_name: "TopicCategory", foreign_key: :topic_category_id

  has_many :receives, class_name: "TopicReceive", dependent: :destroy

  validates :content, :presence => true

  validates_presence_of :user
  validates_presence_of :owner

  #puliceity: 公开, external: 扩展, circle: 限定范围
  acts_as_status :status, [:puliceity, :external, :circle]

  def receive_users
    users = []
    receives.includes(:receive).each do |r|
      if r.receive
        users << if r.receive.is_a?(Circle)
          r.receive.friend_users
        else
          r.receive.as_json(methods: :icon)
        end
      end
    end
    users.flatten
  end

  def self.users(options = {})
    where(options.merge(:owner_type => "User"))
  end

  def self.shops(options = {})
    where(options.merge(:owner_type => "Shop"))
  end

  #获取某个商店的所有与它有关的贴
  def self.find_shop_or_friends(shop_id, circles)
    shop = Shop.find(shop_id)
    scope_related(shop, circles)
  end

  #获取某个用户的所有与它有关的贴
  def self.find_user_or_friends(user_id, circles)
    user = User.find(user_id)
    scope_related(user, circles)
  end

  def as_json(*args)
    attribute = super *args
    attribute["avatar_url"] = owner.photos.icon if owner.is_a?(Shop)
    attribute["avatar_url"] = owner.icon if owner.is_a?(User)
    attribute["status"] = status.name
    attribute["send_login"] = user.login
    attribute["status_name"] = I18n.t("topic.#{status.name}")
    attribute["topic_category_name"] = category.name unless category.nil?
    if status == :puliceity && receives.count > 0
      attribute["receive_shop_name"] = receives.first.receive.name
    end
    #attribute["owner_shop"] = owner.name unless owner.nil? && owner.is_a?(Shop)

    attribute
  end

  class << self
    def receive_other(friends)
      receives = []
      friends.each do |i, f|
        friend = f.symbolize_keys
        receive = Kernel.const_get(friend[:status].classify).find_by(id: friend[:id])
        receives << receive unless receive.nil?
      end
      {status: :circle, circles: receives}
    end

    def is_level(friends, id)
      _status = false
      friends.each do |i, f|
        friend = f.symbolize_keys
        if friend[:id] == id && friend[:status] == "scope"
          _status = true
          break
        end
      end
      _status
    end

    private
    def scope_related(_owner, circles)
      wh = circles == :all ?  "" : " and status=1"
      circles = _owner.circles if circles == :all

      owner_type = _owner.class.name
      owner_id = _owner.id
      #获取圈子的好友
      user_ids = circles.includes(:friends).map{|c| c.friends.map{|f| f.user_id} }.flatten
      #获取与我相关的贴,去除不是我好友的贴
      topic_ids = receive_topics(owner_type, owner_id)
      #获取圈子的发贴
      ctopic_ids = receive_topics("Circle", circles.map{|c| c.id})

      where("(owner_id=? and owner_type=? #{wh})" +
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
