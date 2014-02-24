class User < ActiveRecord::Base
  include Graphical::Display
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Tire::Model::UpdateByQuery
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
  
  has_many :answer_ask_buys

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
  has_many :money_bills, :dependent => :destroy
  has_many :transfer_moneys, :dependent => :destroy
  has_many :activities, foreign_key: "author_id", class_name: "Activity", dependent: :destroy
  has_many :ask_buies, class_name: "AskBuy", :dependent => :destroy
  has_many :banks, :dependent => :destroy, class_name: "UserBank"
  has_many :withdraw_money, :dependent => :destroy, class_name: "WithdrawMoney"


  # has_and_belongs_to_many :services

  after_create :load_initialize_data

  delegate :groups, :jshop, :to => :shop_user, :allow_nil => true

  after_initialize :init_user_info

  def liked_activities
    Activity.joins("left join activities_likes as al on activities.id = al.activity_id left join users on users.id = al.user_id").where("users.id = ?", id)
  end

  def answered_ask_buy(ask_buy_id)
    AnswerAskBuy.where(:ask_buy_id => ask_buy_id, :user_id => self.id).first
  end

  def city
    user_checking.try(:address).try(:city)
  end

  def area
    user_checking.try(:address).try(:area)
  end

  def address_location
    user_checking.try(:address).try(:location)
  end

  # 收入
  # options: {
  #   owner => '所属类型 (订单 退货 或者是用户)'
  #   decription => '描述',
  #   source => '来源',
  #   state => '即时到帐状态', #false 不可以用余额 true 可用余额 默认false
  #   pay_type => '支付类型(帐户 快钱 银行汇款) 默认帐户'
  # }
  def recharge(money, options = {})
    transfer_moneys.income!(
      options.merge(:money => money))
  end

  # 支付
  # optioins: {
  #   target => '目标',
  #   decription => '描述',
  #   owner => '所属类型 (订单 退货 或者是用户)',
  #   state => '即时到帐状态', #false 不可以用余额 true 可用余额 默认false
  #   pay_type => '支付类型(帐户 快钱 银行汇款) 默认帐户'
  # }
  def payment(_money, opts = {})
    options = opts.symbolize_keys

    target = options.delete(:target)
    state = options.delete(:state)
    pay_type = options.delete(:pay_type) || :account

    raise "支付出错, 没有目标参数" if target.blank? || !target.is_a?(User)      
    raise "支付出错, 没有所属类型" unless options.key?(:owner)

    transfer_moneys.pay_out!(options.merge(
      :source => target,
      :pay_type => pay_type,
      :money => _money))

    target.recharge(_money, 
      options.merge(
        :source => self,
        :state => state))
  end

  def money
    if persisted?
      reload
      read_attribute("money") || 0
    else
      0
    end
  end

  def valid_money?(_money)
    money < _money
  end

  def unavailable_money
    money_bills.unavailable
  end

  def messages(friend_id)
    chat_messages.all(id, friend_id)
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

  def recount_money
    self.update_attribute(:money, money_bills.available)
  end

  def as_json(*args)
    attribute = super *args
    # attribute["icon_url"] = icon
    # attribute["avatar_url"] = avatar
    # attribute["header_url"] = photos.header
    attribute["photos"] = photos.attributes

    attribute
  end

  def industry_type
    user_checking.try(:industry_type)
  end

  def belongs_shop
    self.is_seller? ? shop : jshop
  end

  def phone
    user_checking.try(:phone)
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
    services.include?("seller")
  end

  # def chat_notify(send_user, receive_user, content)
  #   notify("/chat",
  #     "#{send_user.login}说: #{content}",
  #     :send_user_id => send_user.id,
  #     :persistent => false)
  # end

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

  #
  # 给此用户发送通知
  #
  # @param  channel [String, ActiveRecord::Base] 频道名称，或模型对象
  # @param  data [String] 发送数据类容
  # @param  options [Hash] 通知选项
  #
  # @see http://localhost:8808/docs/Notification#create%21-class_method Notification::create!
  def notify(channel, data, options = {})
    options.symbolize_keys!

    # if options[:avatar].blank?
    #   options[:avatar] = self.avatar
    # end

    Notification.create!(self, channel, data, options)
  end

  def permissions
    groups.map{| g | g.permissions}
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

  def to_indexed_json
    {
      :login => login,
      :email => email,
      :photos => photos.attributes,
      :address_id => user_checking.try(:address_id),
      :address => user_checking.try(:address).try(:address_only),
      :industry_type => user_checking.try(:industry_type),
      :service => user_checking.try(:service),
      :phone => user_checking.try(:phone)
    }.to_json
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
        :user => {
          :photos => {
            :icon => photos.icon,
            :header => photos.header,
            :avatar => photos.avatar
          }
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

  def services
    @services ||= (read_attribute(:services) || "").split(',')
  end

  def add_service(service)
    services.push service unless services.include?(service)
    write_attribute(:services, services.join(','))
  end

  private

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
