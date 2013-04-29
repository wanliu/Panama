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
  include Extract::Mention
  include TextFormatHtml::Configure

  scope :puliceity, where(:status => 1)
  scope :external, where(:status => 2)
  scope :circle, where(:status => 3)
  scope :community, where(:status => 4)

  attr_accessible :content, :owner_id, :owner_type, :user_id, :content_html, :status, :topic_category_id

  belongs_to :owner, :polymorphic => true
  belongs_to :user
  belongs_to :category, class_name: "TopicCategory", foreign_key: :topic_category_id

  has_many :receives, class_name: "TopicReceive", dependent: :destroy
  has_many :comments, as: :targeable, dependent: :destroy
  has_many :attachments, class_name: "TopicAttachment", dependent: :destroy

  validates :content, :presence => true

  validates_presence_of :user
  validates_presence_of :owner

  validate :valid_status?

  #puliceity: 公开, external: 扩展, circle: 限定范围, community: 商家圈
  acts_as_status :status, [:puliceity, :external, :circle, :community]

  before_save :content_format_html

  def content_format_html
    self.content_html = text_format_html(self.content)
  end

  def receive_users
    users = []
    receives.includes(:receive).each do |r|
      unless r.receive.is_a?(Shop)
        users << if r.receive.is_a?(Circle)
          r.receive.friend_users
        else
          r.receive.as_json
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
    attribute["attachments"] = []
    attachments.each do |atta|
      attribute["attachments"] << atta.attachment.file.url
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
      circles = _owner.circles if circles == :all
      #获取圈子的好友
      user_ids = circle_friends(circles)
      #获取与我相关的贴,去除不是我好友的贴
      topic_ids = receive_topics(_owner.class.name, _owner.id)
      #获取圈子的发贴
      ctopic_ids = receive_topics("Circle", circle_ids(circles))
      where("#{owner_condit(_owner, circles)} " +
        " or #{user_condit} or #{receive_oneself_condit} or #{circle_condit}",
        user_ids, topic_ids, user_ids, ctopic_ids)
    end

    #所属的公开或者所属的条件
    def owner_condit(_owner, circles)
      wh = circles == :all ?  "" : " and status=1"
      "(owner_id=#{_owner.id} and owner_type='#{_owner.class.name}' #{wh})"
    end

    #好友的公开条件
    def user_condit
      "(owner_id in (?) and owner_type ='User' and status=1)"
    end

    #好友指定接收者的帖子条件
    def receive_oneself_condit
      "(id in (?) and owner_type='User' and owner_id in (?) )"
    end

    def circle_condit
      "id in (?)"
    end

    def circle_ids(circle)
      circle.is_a?(Circle) ? [circle.id] : circle.map{|c| c.id}
    end

    def circle_friends(circle)
      if circle.is_a?(Circle)
        circle.friends.map{|f| f.user_id}
      else
        circle.includes(:friends).map{|c| c.friends.map{|f| f.user_id} }.flatten
      end
    end

    def receive_topics(receive_type, receive_id)
      TopicReceive.where(receive_type: receive_type, receive_id: receive_id)
      .select("distinct topic_id").order('created_at desc').map{|t| t.topic_id}
    end
  end

  private
  def valid_status?
    errors.add(:status, "无效的状态！") if status == :invalid
  end

  def valid_category?
    if category.nil? && status == :community
      errors.add(:category_id, "没有选择分类")
    end
  end
end