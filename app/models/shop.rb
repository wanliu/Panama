#encoding: utf-8
require 'orm_fs'

class Shop < ActiveRecord::Base
  mount_uploader :photo, ImageUploader

  include Graphical::Display
  include Tire::Model::Search 
  include Tire::Model::Callbacks 
  include Tire::Model::UpdateByQuery
  extend FriendlyId

  attr_accessible :name, :user, :address, :shop_summary, :address_id, :shop_url, :audit_count, :photo
  attr_accessor :uploader_secure_token  

  has_many :products, :class_name => "ShopProduct", dependent: :destroy
  has_many :groups, dependent: :destroy, class_name: "ShopGroup"
  has_many :transactions, class_name: "OrderTransaction", :foreign_key => "seller_id"
  has_many :shop_users
  has_many :contents, :as => :contentable, dependent: :destroy
  has_many :followers, as: :follow, class_name: "Following", dependent: :destroy
  has_many :circles, as: :owner, class_name: "Circle", dependent: :destroy
  has_many :topics, as: :owner, dependent: :destroy
  has_many :direct_transactions, :foreign_key => "seller_id"
  has_many :order_refunds, :foreign_key => "seller_id"
  has_many :invites, :as => :targeable, class_name: 'InviteUser'
  belongs_to :address

  has_one :shops_category
  belongs_to :user 

  alias_method :owner, :user

  before_destroy :delete_shop

  delegate :banks, :to => :user

  after_commit do
    update_relation_index
  end

  before_create do
    generate_im_token
  end

  after_create do
    generate_employee
  end

  scope :actived, where(actived: true)

  validates :name, format: { with: /^[a-zA-Z0-9_\u4e00-\u9fa5]+$/, message: "只能包含数字、字母、汉字和下划线（_­）组成，不能有空格" }
  validates :name, presence: true
  validates :name, uniqueness: true

  validates_presence_of :user

  define_graphical_attr :photos, :handler => :photo
  friendly_id :name

  def shutdown_shop
    update_attribute(:actived, false)
  end

  def address_location
    address.try(:location)
  end

  def active
    update_attribute(:actived, true)
  end

  def configure_shop
    if audit_count == 1
      create_shop
      initial_shop_data
    end
  end

  #shop 的所有的圈子，包括店主个人的
  def all_type_circles
    Circle.where("owner_type='Shop' and owner_id=? or owner_type='User' and owner_id=?",id, user.id)
  end

  #加入的商店商圈
  def circle_all
    circle_ids = CircleFriends.where(:user_id => user.id).pluck(:circle_id)
    Circle.where("owner_type='Shop' and id in (?)", circle_ids)
  end

  #所有圈子好友
  def circle_all_friends
    CircleFriends.where(:circle_id => circles.map{|c| c.id})
  end

  def is_follower?(user_id)
    followers.exists?(user_id: user_id)
  end

  #所有好友的圈子
  def all_friend_circles
    user_ids = circle_all_friends.select(:user_id).map{|f| f.user_id}
    Circle.where(:owner_type => "User",:owner_id => user_ids)
  end

  def has_product(product_id)
    ShopProduct.find_by(:product_id => product_id, :shop_id => self.id)
  end

  def as_json(*args)
    attribute = super *args
    attribute["photos"] = photos.attributes
    attribute
  end

  def to_indexed_json
    {
      :name => name,
      :address_id => address_id,
      :address => address.try(:address_only),
      :user => {
        :id => user_id,
        :login => user.try(:login),
        :photos => user.try(:photos).try(:attributes)
      },
      :actived => actived,
      :audit_count => audit_count,
      :shop_summary => shop_summary,
      :shop_url => shop_url,
      :photos => photos.attributes,
      :industry_type => user.try(:industry_type),
      :phone => user.try(:phone)
    }.to_json
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
    User.where(:id => shop_users.pluck("user_id"))
  end

  def is_employees?(user)
    uid = user.is_a?(User) ? user.id : user
    shop_users.exists?(["user_id=?", uid])
  end

  def join_employee(user)
    uid = user.is_a?(User) ? user.id : user
    shop_users.create(:user_id => uid)
  end

  def generate_employee
    shop_users.create(:user_id => user_id)
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

  def notify(channel, data, options = {})
    # exclude = options.key?(:exclude) ? options.delete(:exclude) : []
    # exclude = [exclude] unless exclude.is_a?(Array)
    # (employees - exclude).each do |member|
    #   member.notify(File.join("/shops", channel), data, options)
    # end
    user.notify(File.join("/shops", channel), data, options)
  end

  def update_relation_index
    update_activity_index
    update_shop_product_index
  end

  def update_activity_index
    Activity.index_update_by_query(
      :query => {
        :term => {
          "shop.id" => id
        }
      },
      :update => {
        :shop => {
          :photos => {
            :icon => photos.icon,
            :header => photos.header,
            :avatar => photos.avatar
          }
        }
      }
    )
  end

  def update_shop_product_index
    ShopProduct.index_update_by_query(
      :query => {
        :term => {
          "seller.id" => id
        }
      },
      :update => {
        :seller => {
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

  def create_shop
    copy_standardization_files

    load_default_contents

    write_default_options
  end

  def initial_shop_data
    # @category = shops_category.blank? ? create_shops_category(:name => "#{name}_root") : shops_category
    # @category.load_default

    load_group
    load_group_permission
    load_admin_permission
    # load_friend_circle
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
