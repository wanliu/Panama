#encoding: utf-8
#describe: 关注
class Following < ActiveRecord::Base
  attr_accessible :follow_id, :follow_type, :user_id, :user, :follow
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
    if follow.is_a?(User)
      follow.notify("/follow",
                    "用户 #{user.login} 关注了您",
                    :target => self,
                    :url => "/people/#{user.login}",
                    :avatar => user.avatar,
                    :follow_state => follow.is_follow_user?(user.id),
                    :user =>  user)
      
    elsif follow.is_a?(Shop)
      follow.notify("/follow",
                    "用户 #{user.login} 关注了您的商店",
                    :target => self,
                    :url => "/people/#{user.login}",
                    :avatar => user.avatar,
                    :user => user,
                    :followed_user => follow.user.login,
                    :shop_name => follow.name)
    end
  end

  after_destroy do
    if follow.is_a?(User)
      follow.notify("/unfollow",
                    "用户 #{user.login} 取消关注了您",
                    :target => self,
                    :url => "/people/#{user.login}",
                    :avatar => user.avatar)
    elsif follow.is_a?(Shop)
      follow.notify("/unfollow",
                    "商家 #{user.login} 不再关注您的商店了",
                    :target => self,
                    :url => "/people/#{user.login}",
                    :avatar => user.avatar)
    end
  end

  # 当相互关注后，才能添加持久化的通道
  after_create do
    if follow.is_a?(User) && follow.is_follow_user?(user.id)
      PersistentChannel.where(:user_id => user.id,
                              :name => follow.login,
                              :icon => follow.avatar,
                              :channel_type => 1)
                       .first_or_create

      PersistentChannel.where(:user_id => follow.id,
                              :name => user.login,
                              :icon => user.avatar,
                              :channel_type => 1)
                       .first_or_create
    end
  end

  after_destroy do
    if follow.is_a?(User) && follow.is_follow_user?(user.id)
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

  def self.is_exist?(follow)
    params = follow.attributes.delete_if { |key, value| value.nil? }
    Following.exists?(params)
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
