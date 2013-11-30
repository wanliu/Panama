#encoding: utf-8
#describe: 关注
class Following < ActiveRecord::Base
  attr_accessible :follow_id, :follow_type, :user_id
  scope :shops, where(follow_type: "Shop")
  scope :users, where(follow_type: "User")

  belongs_to :user
  belongs_to :follow, :polymorphic => true
  belongs_to :target, :polymorphic => true

  validates :user_id, :presence => true
  validates_presence_of :user
  validates_presence_of :follow
  validate :valid_follow?

  after_create do
    member_id = follow.is_a?(User) ? follow_id : follow.user.id  
    body = follow.is_a?(User) ? "#{ user.login}关注了你" : "#{ user.login}关注了你的商店 #{ follow.name }"
    Notification.create!(
      :user_id => user_id,
      :mentionable_user_id => member_id,
      :url => "/people/#{user.login}/notifications",
      :targeable => self,
      :body => body )
  end

  def self.user(user_id, uid = nil)
    opts = {follow_id: user_id, follow_type: "User"}
    opts[:follow_id] = user_id.id if user_id.is_a?(User)
    opts.merge!(user_id: uid) unless uid.nil?
    create(opts)
  end

  def self.shop(shop_id, uid = nil)
    opts = {follow_id: shop_id, follow_type: "Shop"}
    opts[:follow_id] = shop_id.id if shop_id.is_a?(Shop)
    opts.merge!(user_id: uid) unless uid.nil?
    create(opts)
  end

  def valid_follow?
    if Following.exists?(["follow_id=? and follow_type=? and id<>? and user_id=?",
      follow_id, follow_type, id.to_s, user_id])
      errors.add(:follow_id, "已经是你关注对象!")
    end
  end

  def as_json(*args)
    attribute = super *args
    case self.follow_type
    when "User"
      attribute["login"] = User.find(self.follow_id).login
    when "Shop"
      attribute["name"] = Shop.find(self.follow_id).name
    end
    attribute["follow_type"] = self.follow_type
    attribute["follow_id"] = self.follow_id
    attribute
  end
end
