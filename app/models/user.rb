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
  has_many :addresses, as: :targeable, class_name: "Address", dependent: :destroy
  has_many :followings, dependent: :destroy
  has_many :followers, :as => :follow, :class_name => "Following", dependent: :destroy
  has_many :circles, as: :owner, class_name: "Circle", dependent: :destroy
  has_many :circle_friends, class_name: "CircleFriends", dependent: :destroy
  has_many :topics, as: :owner, dependent: :destroy
  has_many :topic_receives, as: :receive, dependent: :destroy, class_name: "TopicReceive"
  has_many :friend_groups, dependent: :destroy
  has_many :contact_friends, dependent: :destroy
  has_many :chat_messages, foreign_key: "send_user_id", dependent: :destroy
  has_many :receive_messages, foreign_key: "receive_user_id", class_name: "ChatMessage", dependent: :destroy
  has_many :money_bills, :dependent => :destroy
  has_many :activities, foreign_key: "author_id", class_name: "Activity", dependent: :destroy
  has_and_belongs_to_many :services

  delegate :groups, :jshop, :to => :shop_user

  after_create :load_initialize_data
  before_create :generate_token

  delegate :groups, :jshop, :to => :shop_user

  after_initialize :init_user_info

  def recharge(money, owner)
    money_bills.create!(
      :money =>money,
      :owner => owner)
  end

  def payment(money, owner)
    money_bills.create!(
      :money => -money,
      :owner => owner)
  end

  def money
    reload
    read_attribute("money") || 0
  end

  def messages(friend_id)
    ChatMessage.all(id, friend_id)
  end

  def connect
    RedisClient.redis.set(redis_key, true)
    FayeClient.send("/chat/friend/connect/#{id}", id)
  end

  def connect_state
    RedisClient.redis.exists(redis_key)
  end

  def generate_token
    self.im_token = SecureRandom.hex
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

  def following_shop_topics
    shop_ids = followings.shops.includes(:follow).map{|u| u.follow.id }
    topic_ids = TopicReceive.shop_related(shop_ids).map{|t| t.topic_id }
    Topic.community.where(:id => topic_ids)
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
    load_circle
    load_friend_group
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

  def format_followings
    followings.map do |following|
      case following.follow_type
      when "User"
        { name: User.find(following.follow_id).login,
          follow_type: "User",
          follow_id: following.follow_id }
      when "Shop"
        { name: Shop.find(following.follow_id).name,
          follow_type: "Shop",
          follow_id: following.follow_id }
      end
    end
    # following_types = following.ground_by { |following| following.type }
    # following_users = following_types["User"]
    # following_shops = following_types["Shop"]
  end

  private
  def load_circle
    _config = YAML.load_file("#{Rails.root}/config/data/user_circle.yml")
    _config["circle"].each do |circle|
      self.circles.create(circle) if self.circles.find_by(circle).nil?
    end
  end

  def load_friend_group
    _config = YAML.load_file("#{Rails.root}/config/data/friend_group.yml")
    _config["friend_group"].each do |name|
      self.friend_groups.create(name) if self.friend_groups.find_by(name).nil?
    end
  end
end
