class User < ActiveRecord::Base
  include Graphical::Display
  extend FriendlyId

  attr_accessible :uid, :login, :first_name, :last_name

  define_graphical_attr :photos, :handler => :grapical_handler

  friendly_id :login

  has_one :cart
  has_one :photo, :as => :imageable, :class_name => "Image"
  has_one :shop

  has_many :transactions,
           class_name: "OrderTransaction",
           foreign_key: 'buyer_id'

  has_many :addresses, class_name: "Address"

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

    if photo.nil?
      build_photo
      # save
    end
  end
end
