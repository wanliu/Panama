class ShopUser < ActiveRecord::Base
  attr_accessible :user_id

  belongs_to :user
  belongs_to :shop

  has_many :shop_user_groups, :dependent => :destroy
end
