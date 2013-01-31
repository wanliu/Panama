class User
  include Mongoid::Document
  attr_accessible :uid, :login, :first_name, :last_name

  field :uid, type: String
  field :login, type: String
  
  has_one :cart
  has_one :image, :as => :imageable
  has_many :transactions, inverse_of: :buyer
  has_many :addresses, as: :addressable, class_name: "Address"
  
  alias :avatar :image

  after_initialize do 
    if cart.nil?
      create_cart
      save
    end

    if image.nil?
      create_image
      save
    end
  end
end
