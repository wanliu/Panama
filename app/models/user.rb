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
  has_many :circles, as: :owner, class_name: "Circle", dependent: :destroy
  has_many :circle_friends, class_name: "CircleFriends", dependent: :destroy
  has_many :friend_groups, dependent: :destroy
  has_many :contact_friends, dependent: :destroy
  # has_many :chat_messages, foreign_key: "send_user_id", dependent: :destroy
  # has_many :receive_messages, foreign_key: "receive_user_id", class_name: "ChatMessage", dependent: :destroy
  has_many :chat_messages, :as => :owner, dependent: :destroy
  has_many :money_bills, :dependent => :destroy
  has_many :activities, foreign_key: "author_id", class_name: "Activity", dependent: :destroy
  has_many :ask_buies

  has_and_belongs_to_many :services

  delegate :groups, :jshop, :to => :shop_user

  after_create :load_initialize_data
  before_create :generate_token

  after_update do
    update_relation_index
  end

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

  def circle_all
    circle_ids = CircleFriends.where(:user_id => id).pluck(:circle_id)
    Circle.where("(owner_id=? and owner_type='User') or id in (?)", id, circle_ids)
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

  def update_relation_index
    update_activity_index
    update_ask_buy_index
  end

  def update_ask_buy_index
    AskBuy.index_update_by_query(
      :query => {
        :term => {
          "user.id" => id
        }
      },
      :update => {
        :photos => {
          :icon => photos.icon,
          :header => photos.header,
          :avatar => photos.avatar
        }
      }
    )
  end

  def update_activity_index
    Activity.index_update_by_query(
      :query => {
        :term => {
          "author.id" => id
        }
      },
      :update => {
        :author => {
          :photos => {
            :icon => photos.icon,
            :header => photos.header,
            :avatar => photos.avatar
          }
        }
      }
    )
  end

  private

  def load_friend_group
    _config = YAML.load_file("#{Rails.root}/config/data/friend_group.yml")
    _config["friend_group"].each do |name|
      self.friend_groups.create(name) if self.friend_groups.find_by(name).nil?
    end
  end
end
