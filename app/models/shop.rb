#encoding: utf-8
require 'orm_fs'

class Shop < ActiveRecord::Base
  include Graphical::Display
  extend FriendlyId

  attr_accessible :name, :user
  attr_accessor :uploader_secure_token

  has_many :products, :class_name => "ShopProduct", dependent: :destroy
  has_many :groups, dependent: :destroy, class_name: "ShopGroup"
  has_many :transactions, class_name: "OrderTransaction", :foreign_key => "seller_id"
  has_many :shop_users
  has_many :contents, :as => :contentable, dependent: :destroy
  has_many :followers, as: :follow, class_name: "Following", dependent: :destroy
  has_many :circles, as: :owner, class_name: "Circle", dependent: :destroy
  has_many :topics, as: :owner, dependent: :destroy
  has_many :topic_receives, as: :receive, dependent: :destroy, class_name: "TopicReceive"
  has_many :topic_categories, dependent: :destroy
  has_many :banks, :class_name => "ShopBank", :dependent => :destroy
  has_many :direct_transactions, :foreign_key => "seller_id"
  # has_one  :address, as: :targeable, class_name: "Address", dependent: :destroy
  # has_many :pay_manners, dependent: :destroy, class_name: "PayManner"
  # has_many :delivery_manners, dependent: :destroy, class_name: "DeliveryManner"

  has_one :shops_category
  belongs_to :user

  before_create :create_shop
  after_create :initial_shop_data
  before_destroy :delete_shop

  scope :actived, where(actived: true)

  validates :name, presence: true
  validates :name, uniqueness: true

  validates_presence_of :user

  mount_uploader :photo, ImageUploader
  define_graphical_attr :photos, :handler => :photo  
  friendly_id :name

  #所有圈子好友
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
    attribute["photos"] = photos.attributes
    attribute["icon_url"] = icon_url

    attribute
  end

  def all_circle_topics(circles)
    Topic.find_shop_or_friends(id, circles)
  end

  def fs
    require "orm_fs"
    "/_shops/#{name}".to_dir
  end

  #所有商店的雇员
  def employees
    shop_users.includes(:user).map{| su | su.user } + [user]
  end

  def seller_group_employees
    group = groups.find_by(:name => "seller")
    group.nil? ? [] : group.users
  end

  #查询这个商店是否有这个雇员
  def find_employee(userid)
    shop_users.find_by(:user_id => userid)
  end

  def actived?
    actived
  end

  class << self
    attr_reader :slient_state

    def slient!
      @@slient_state = true
    end

    def unslient!
      @@slient_state = false
    end
  end

  def lookup_content(name)
    contents.where(:name => name).first
  end

  def icon_url
    photos.icon
  end

  def generate_im_token
    self.im_token = SecureRandom.hex
  end

  private

  def create_shop
    copy_standardization_files

    load_default_contents

    write_default_options

    generate_im_token
  end

  def initial_shop_data
    @category = shops_category.blank? ? create_shops_category(:name => "#{name}_root") : shops_category
    @category.load_default

    load_group
    load_group_permission
    load_admin_permission
    load_friend_circle
    load_topic_category
  end

  def delete_shop
    remove_standardization_files
  end

  def load_friend_circle
    _config = YAML.load_file("#{Rails.root}/config/data/shop_circle.yml")
    _config["circle"].each do |circle|
      self.circles.create(circle) if self.circles.find_by(circle).nil?
    end
  end

  def load_topic_category
    _config = YAML.load_file("#{Rails.root}/config/data/topic_category.yml")
    _config["topic_categories"].each do |category|
      self.topic_categories.create(category) if self.topic_categories.find_by(category).nil?
    end
  end

  def load_group
    _config = YAML.load(fs['config/shop_group.yml'].read)
    _config["shop_group"].each do |group|
      self.groups.create(group) if self.groups.find_by(group).nil?
    end
  end

  def load_group_permission
    _config = YAML.load_file("#{Rails.root}/config/data/permission.yml")
    _config["group_permission"].each do |group_name, permissions|
      group = self.groups.find_by(name: group_name)
      group.give_permission(permissions) unless group.nil?
    end
  end

  def load_admin_permission
    group = self.groups.find_by(name: "admin")
    group.give_all_permission unless group.nil?
  end

  def load_default_contents
    _config = YAML.load(fs['config/contents.yml'].read)
    _config['contents'].each do |content|
      self.contents << Content.create(content)
    end
  end

  def copy_standardization_files
    base = default_shop_path
    shop_path_pattern = File.join(base, "**/*")

    root = create_vfs_workspace

    Dir[shop_path_pattern].each do |path|
      unless File.directory?(path)
        file = path.to_s.sub base + '/', ''
        copy_local_to_vfs file, root
      end
    end
  end

  def remove_standardization_files
    # fs['**/*'].each do |path|
    #   path.destroy
    # end
  end

  def default_shop_path
    Rails.application.config.default_shop_path.to_s
  end

  # 创新 商店的 虚拟文件系统
  def create_vfs_workspace
    fs
  end

  def write_default_options
  end

  def copy_local_to_vfs file, root
    path = File.join default_shop_path, file
    File.open(path, 'r') do |f|
      puts file if Shop.slient_state
      root[file].write f.read
    end
  end
end
