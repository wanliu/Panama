class Admin < ActiveRecord::Base
  attr_accessible :login, :uid
end
