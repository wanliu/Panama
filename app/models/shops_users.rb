class ShopsUsers < ActiveRecord::Base
  attr_accessible :shop_id, :user_id

  belongs_to :user
  belongs_to :shop
end
