class User
  include Mongoid::Document
  attr_accessible :uid, :login, :first_name, :last_name

  field :uid, type: String
  field :login, type: String
  
end
