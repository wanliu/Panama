class Mongodb::User
  include Mongoid::Document
  include Graphical::Display

  attr_accessible :uid, :login, :first_name, :last_name

  define_graphical_attr :photos, :handler => :photo, :allow => [:icon, :header, :avatar, :preview]

  configrue_graphical :icon => "30x30",  :header => "100x100", :avatar => "420x420", :preview => "420x420"

  field :uid, type: String
  field :login, type: String
  
  has_one :cart
  has_one :photo, :as => :imageable, :class_name => "Image"
  has_many :transactions, inverse_of: :buyer
  has_many :addresses, class_name: "Address"
  
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
