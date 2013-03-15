class ShopUser < ActiveRecord::Base
  attr_accessible :user_id

  belongs_to :user
  belongs_to :shop

  has_many :shop_user_groups, :dependent => :destroy

  def groups
  	shop_user_groups.map{|g| g.shop_group }
  end

  def jshop
  	shop
  end
end
