require 'orm_fs'

class Shop < ActiveRecord::Base
  include Graphical::Display
  extend FriendlyId

  attr_accessible :name, :user

  has_many :contents, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :groups, dependent: :destroy, class_name: "ShopGroup"
  has_many :transactions, class_name: "OrderTransaction", :foreign_key => "seller_id"
  has_many :shop_users

  has_one :shops_category
  belongs_to :user

  before_create :create_shop
  after_create :initial_shop_data
  before_destroy :delete_shop

  validates :name, presence: true
  validates :name, uniqueness: true

  validates_presence_of :user

  mount_uploader :photo, ImageUploader
  define_graphical_attr :photos, :handler => :photo, :allow => [:icon, :header, :avatar, :preview]
  configrue_graphical :icon => "30x30",  :header => "100x100", :avatar => "420x420", :preview => "420x420"
  friendly_id :name

  def fs
    require "orm_fs"
    "/_shops/#{name}".to_dir
  end

  #所有商店的雇员
  def employees
    shop_users.map{| su | su.user }
  end

  #查询这个商店是否有这个雇员
  def find_employee(userid)
    shop_users.find_by(:user_id => userid)
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

  private

  def create_shop
    copy_standardization_files

    load_default_contents

    write_default_options
  end

  def initial_shop_data
    @category = shops_category.blank? ? create_shops_category(:name => name + "_" + "root") : shops_category
    @category.load_default

    load_group
    load_group_permission
    load_admin_permission
  end

  def delete_shop
    remove_standardization_files
  end

  def load_group
    _config = YAML.load(fs['config/shop_group.yml'].read)
    _config["shop_group"].each do |group|
      if self.groups.find_by(group).nil?
        self.groups.create(group)
      end
    end
  end

  def load_group_permission
    _config = YAML.load_file("#{Rails.root}/config/permission.yml")
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
