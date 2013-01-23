class User
  include Mongoid::Document
  attr_accessible :uid, :login, :first_name, :last_name

  field :uid, type: String
  field :login, type: String
  
  has_one :_cart, :class_name => "Cart"

  def cart
    if _cart.nil?
      _cart = Cart.create
      save
    end
    _cart
  end
end
