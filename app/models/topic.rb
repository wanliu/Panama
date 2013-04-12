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
  scope :puliceity, where(:status => 1)
  scope :external, where(:status => 2)
  scope :circle, where(:status => 3)
  scope :community, where(:status => 4)

  attr_accessible :content, :owner_id, :owner_type, :user_id, :content_html, :status, :topic_category_id

  belongs_to :owner, :polymorphic => true
  belongs_to :user
  belongs_to :category, class_name: "TopicCategory", foreign_key: :topic_category_id

  has_many :receives, class_name: "TopicReceive", dependent: :destroy
  has_many :comments, as: :targeable

  validates :content, :presence => true

  validates_presence_of :user
  validates_presence_of :owner

  #puliceity: 公开, external: 扩展, circle: 限定范围, community: 商家圈
  acts_as_status :status, [:puliceity, :external, :circle, :community]

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
  def self.find_shop_or_friends(shop, circles)
    shop = Shop.find(shop) unless shop.is_a?(Shop)
    scope_related(shop, circles)
  end

  #获取某个用户的所有与它有关的贴
  def self.find_user_or_friends(user, circles)
    user = User.find(user) unless user.is_a?(User)
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
    if status == :community && receives.count > 0
      attribute["receive_shop_name"] = receives.first.receive.name
    end

    attribute
  end

  class << self
    def receive_other(friends)
      data = {status: :circle, circles: []}
      friends.each do |i, f|
        if f[:status] != "scope"
          friend = f.symbolize_keys
          receive = find_receive(friend[:status].classify, friend[:id])
          if receive.is_a?(Shop)
            data[:status] = :community
            data[:circles] = [receive]
            break
          else
            data[:circles] << receive unless receive.nil?
          end
        end
      end
      data
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
    def find_receive(class_name, id)
      Kernel.const_get(class_name).find_by(id: id)
    end

    def scope_related(_owner, circles)
      wh = circles == :all ?  "" : " and status=1"
      circles = _owner.circles if circles == :all
      owner_type, owner_id = _owner.class.name, _owner.id
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
