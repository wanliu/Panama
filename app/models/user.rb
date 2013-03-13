class User < ActiveRecord::Base
  include Graphical::Display
  extend FriendlyId

  attr_accessible :uid, :login, :first_name, :last_name, :email

  define_graphical_attr :photos, :handler => :grapical_handler

  friendly_id :login

  has_one :cart
  has_one :photo, :as => :imageable, :class_name => "Image"
  has_one :shop

  has_many :transactions,
           class_name: "OrderTransaction",
           foreign_key: 'buyer_id'

  has_many :addresses, class_name: "Address"

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

  def as_json(*args)
    options = super *args
    ps = options["user"]["photos"] ||= {}
    ps["icon"] = photos.icon
    ps["avatar"] = photos.avatar
    options
  end

  after_initialize do
    if cart.nil?
      build_cart
      # save
    end
  end

  def init_user_info
    return if new_record?
    create_photo if photo.nil?
    create_cart if cart.nil?
  end
end
