require 'bunny'

class User < ActiveRecord::Base
  include Graphical::Display
  extend FriendlyId

  attr_accessible :uid, :login, :first_name, :last_name, :email
  attr_protected :money

  define_graphical_attr :photos, :handler => :grapical_handler

  friendly_id :login

  has_one :cart
  has_one :photo, :as => :imageable, :class_name => "Image"
  has_one :shop
  has_one :shop_user
  has_one :user_checking

  has_many :transactions,
           class_name: "OrderTransaction",
           foreign_key: 'buyer_id'
  has_many :direct_transactions,
           class_name: "DirectTransaction",
           foreign_key: "buyer_id"

  has_many :credits
  has_many :delivery_addresses
  has_many :followings, dependent: :destroy
  has_many :followers, :as => :follow, :class_name => "Following", dependent: :destroy
  has_many :persistent_channels
  has_many :circles, as: :owner, class_name: "Circle", dependent: :destroy
  has_many :circle_friends, class_name: "CircleFriends", dependent: :destroy
  has_many :friend_groups, dependent: :destroy
  has_many :contact_friends, dependent: :destroy
  # has_many :chat_messages, foreign_key: "send_user_id", dependent: :destroy
  # has_many :receive_messages, foreign_key: "receive_user_id", class_name: "ChatMessage", dependent: :destroy
  has_many :chat_messages, :as => :owner, dependent: :destroy
  has_many :money_bills, :dependent => :destroy
  has_many :activities, foreign_key: "author_id", class_name: "Activity", dependent: :destroy
  has_and_belongs_to_many :services

  delegate :groups, :jshop, :to => :shop_user

  after_create :load_initialize_data
  after_commit :sync_create_to_redis, :on => :create
  # after_update :sync_change_to_redis
  before_create :generate_token

  delegate :groups, :jshop, :to => :shop_user

  after_initialize :init_user_info

  def generate_token
    self.im_token = SecureRandom.hex
  end

  def liked_activities
    Activity.joins("left join activities_likes as al on activities.id = al.activity_id left join users on users.id = al.user_id").where("users.id = ?", id)
  end

  def city
    user_checking.try(:address).try(:city)
  end

  def area
    user_checking.try(:address).try(:area)
  end

  def recharge(money, owner, decription = "")
    money_bills.create!(
      :decription => decription,
      :money =>money,
      :owner => owner)
  end

  def payment(money, owner, decription = "")
    money_bills.create!(
      :decription => decription,
      :money => -money,
      :owner => owner)
  end

  def money
    reload
    read_attribute("money") || 0
  end

  def messages(friend_id)
    chat_messages.all(id, friend_id)
  end

  def connect
    RedisClient.redis.set(redis_key, true)
    # FayeClient.send("/chat/friend/connect/#{id}", id)
    CaramalClient.publish(login, "/chat/friend/connect/#{id}", id)
  end

  def connect_state
    RedisClient.redis.exists(redis_key)
  end

  def redis_key
    "#{Settings.defaults['redis_key_prefix']}#{id}"
  end

  def join_circles
    circle_friends.joins(:circle).map{|c| c.circle }
  end

  def circle_all_friends
    CircleFriends.where(:circle_id => circles.map{|c| c.id})
  end

  #所有好友的圈子
  def all_friend_circles
    user_ids = circle_all_friends.select(:user_id).map{|f| f.user_id}
    Circle.where(:owner_type => "User",
      :owner_id => user_ids)
  end

  def as_json(*args)
    attribute = super *args
    attribute["icon_url"] = icon
    attribute["avatar_url"] = avatar
    attribute["header_url"] = photos.header
    attribute["photos"] = photos.attributes
    attribute["connect_state"] = connect_state

    attribute
  end

  def icon
    photos.icon
  end

  def value
    login
  end

  def avatar
    photos.avatar
  end

  def is_follow_user?(user_id)
    followings.exists?(follow_id: user_id, follow_type: "User")
  end

  def follow_user(user_id)
    followings.find_by(follow_id: user_id, follow_type: "User")
  end

  def follow_shop(shop_id)
    followings.find_by(follow_id: shop_id, follow_type: "Shop")
  end

  def follow_shop_or_user(id, type)
    followings.find_by(follow_id: id, follow_type: type)
  end

  def is_follow_shop?(shop_id)
    followings.exists?(follow_id: shop_id, follow_type: "Shop")
  end

  def is_follower?(user_id)
    followers.exists?(user_id: user_id)
  end

  def is_seller?
    !services.empty? && services.any? { |service| service.service_type == "seller" }
  end

  def load_initialize_data
    load_friend_group
  end

  def sync_create_to_redis
    # redis_client = RedisClient.redis
    # user_id_to_user_name = RedisClient.redis_keys["user_id_to_user_name"]
    # user_name_to_user_id = RedisClient.redis_keys["user_name_to_user_id"]

    # redis_client.multi do
    #   redis_client.hset(user_id_to_user_name, id, login)
    #   redis_client.hset(user_name_to_user_id, login, id)
    # end
    conn = Bunny.new
    conn.start
    channel = conn.create_channel
    config  = YAML::load_file("config/application.yml")[Rails.env]
    queue_name = config["rabbitmq_queues"]["new_users"]
    queue  = channel.queue(queue_name, :durable => true)

    queue.publish({user_id: id, user_name: login}.to_json)
    conn.close
  end

  def sync_change_to_redis
    if self.login_changed?
      redis_client = RedisClient.redis
      user_id_to_user_name = RedisClient.redis_keys["user_id_to_user_name"]
      user_name_to_user_id = RedisClient.redis_keys["user_name_to_user_id"]

      redis_client.multi do
        old_name = redis_client.hget(user_id_to_user_name, id)
        redis_client.hdel(user_name_to_user_id, old_name)
        redis_client.hset(user_id_to_user_name, id, login)
        redis_client.hset(user_name_to_user_id, login, id)
      end
    end
  end

  #暂时方法
  def grapical_handler
    photo.filename
  end

  def self.exists?(user_id)
    begin
      find(user_id)
    rescue
      false
    end
  end

  #加入的所有的个人的圈子
  def circle_all
    circle_ids = CircleFriends.where(:user_id => id).pluck(:circle_id)
    Circle.where("owner_type='User' and id in (?)", circle_ids)
  end

  #加入的所有的圈子
  def all_circles
    circle_ids = CircleFriends.where(:user_id => id).pluck(:circle_id)
    Circle.where(:id => circle_ids)
  end

  def init_user_info
    if new_record?
      build_photo if photo.nil?
      build_cart if cart.nil?
    else
      create_photo if photo.nil?
      create_cart if cart.nil?
    end
  end

  def has_group?(group)
    groups.include?(group)
  end

  def permissions
    groups.map{| g | g.permissions}
  end

  def self.chat_authorization(from, invested)
    from_user = User.where(login: from).first
    invested_user = User.where(login: invested).first

    if from_user.blank? || invested_user.blank?
      { authorizen: false, denied_reason: "user does't exists!" }
    elsif from_user.in_black_list_of(invested_user)
      { authorizen: false, denied_reason: "investing denied" }
    else
      author_options = system_default_author.merge(invested_user.author_setting)
      white_check_methods = author_options.select do |key, value|
        value == true
      end.keys

      if white_check_methods.any? { |item| invested_user.send(item.to_sym, from_user) }
        { authorizen: true }
      else
        { authorizen: false, denied_reason: "investing denied" }
      end
    end
  end

  def self.group_anthorization(user, group)
  end

  # %w(is_friend is_circle_friend is_following is_follower is_follower_and_is_following)
  def self.system_default_author
    { is_friend: true,
      is_following: true,
      is_circle_friend: true,
      is_follower_and_is_following: true }
  end

  def author_setting
    { is_follower_and_is_following: false }
  end

  def in_black_list_of(another_user)
    false
  end

  def is_friend(another_user)
    true
  end

  def is_following(another_user)
    is_follow_user?(another_user.try(:id))
  end

  def is_follower(another_user)
    is_follower?(another_user.try(:id))
  end

  def is_circle_friend(another_user)
    true
  end

  def is_follower_and_is_following(another_user)
    true
  end

  private
  def load_friend_group
    _config = YAML.load_file("#{Rails.root}/config/data/friend_group.yml")
    _config["friend_group"].each do |name|
      self.friend_groups.create(name) if self.friend_groups.find_by(name).nil?
    end
  end
end
