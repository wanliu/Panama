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

  has_many :addresses, class_name: "Address"
  has_many :credits

  delegate :groups, :jshop, :to => :shop_user

  before_create :generate_token

  def generate_token
    self.im_token = SecureRandom.hex
  end

  def icon
    photos.icon
  end

  def avatar
    photos.avatar
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
end
