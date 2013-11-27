#encoding: utf-8
#describe: 关注
class Following < ActiveRecord::Base
  attr_accessible :follow_id, :follow_type, :user_id
  scope :shops, where(follow_type: "Shop")
  scope :users, where(follow_type: "User")

  belongs_to :user
  belongs_to :follow, :polymorphic => true

  validates :user_id, :presence => true
  validates_presence_of :user
  validates_presence_of :follow
  validate :valid_follow?

  # 当相互关注后，才能添加持久化的通道
  after_create do
    if follow.followings.where('follow_id = ? and follow_type = "User" ', user.id)
      PersistentChannel.where(:user_id => user.id,
                              :name => follow.login,
                              :channel_type => 1)
                       .first_or_create

      PersistentChannel.where(:user_id => follow.id,
                              :name => user.login,
                              :channel_type => 1)
                       .first_or_create
    end
  end

  after_destroy do
    if follow.followings.where('follow_id = ? and follow_type = "User" ', user.id)
      PersistentChannel.where(:user_id => user.id,
                              :name => follow.login,
                              :channel_type => 1)
                       .destroy_all

      PersistentChannel.where(:user_id => follow.id,
                              :name => user.login,
                              :channel_type => 1)
                       .destroy_all
    end
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
