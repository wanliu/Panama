class User < ActiveRecord::Base
  include Graphical::Display
  extend FriendlyId

  attr_accessible :uid, :login, :first_name, :last_name

  define_graphical_attr :photos, :handler => :photo, :allow => [:icon, :header, :avatar, :preview]

  configrue_graphical :icon => "30x30",  :header => "100x100", :avatar => "420x420", :preview => "420x420"

  friendly_id :login

  has_one :cart
  has_one :photo, :as => :imageable, :class_name => "Image"
  has_one :shop

  has_many :transactions,
           class_name: "OrderTransaction",
           foreign_key: 'buyer_id'

  has_many :addresses, class_name: "Address"

  def self.exists?(user_id)
    begin
      find(user_id)
    rescue
      false
    end
  end

  after_initialize do
    if cart.nil?
      create_cart
      save
    end

    if photo.nil?
      create_photo
      save
    end
  end
end
