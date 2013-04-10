class User < ActiveRecord::Base
  include Graphical::Display
  extend FriendlyId

  attr_accessible :uid, :login, :first_name, :last_name, :email

  define_graphical_attr :photos, :handler => :grapical_handler

  friendly_id :login

  has_one :cart
  has_one :photo, :as => :imageable, :class_name => "Image"
  has_one :shop
  has_one :shop_user

  has_many :transactions,
           class_name: "OrderTransaction",
           foreign_key: 'buyer_id'

  has_many :addresses, class_name: "Address", dependent: :destroy
  has_many :followings, dependent: :destroy
  has_many :followers, :as => :follow, :class_name => "Following", dependent: :destroy
  has_many :circles, as: :owner, class_name: "Circle", dependent: :destroy
  has_many :circle_friends, class_name: "CircleFriends", dependent: :destroy
  has_many :topics, as: :owner, dependent: :destroy
  has_many :topic_receives, as: :receive, dependent: :destroy, class_name: "TopicReceive"

  delegate :groups, :jshop, :to => :shop_user

  after_create :load_initialize_data

  def join_circles
    circle_friends.joins(:circle).map{|c| c.circle }
  end

  def all_friends
    CircleFriends.where(:circle_id => circles.map{|c| c.id})
  end

  #所有好友的圈子
  def all_friend_circles
    user_ids = all_friends.select(:user_id).map{|f| f.user_id}
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

    attribute
  end

  def icon
    photos.icon
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

  def load_initialize_data
    _config = YAML.load_file("#{Rails.root}/config/data/user_circle.yml")
    _config["circle"].each do |circle|
      self.circles.create(circle) if self.circles.find_by(circle).nil?
    end
  end

  #暂时方法
  def grapical_handler
    ImageUploader.new
  end

  def self.exists?(user_id)
    begin
      find(user_id)
    rescue
      false
    end
  end

  after_initialize :init_user_info

  after_initialize do
    if cart.nil?
      build_cart
    end
  end

  def init_user_info
    return if new_record?
    create_photo if photo.nil?
    create_cart if cart.nil?
  end

  def has_group?(group)
    groups.include?(group)
  end

  def permissions
    groups.map{| g | g.permissions}
  end
end
