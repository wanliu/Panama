# author: huxinghai
# describe: 商店权限组

class ShopGroup < ActiveRecord::Base
  attr_accessible :name, :shop_id

  belongs_to :shop
  has_many :shop_user_groups

  validates :name, :presence => true, :uniqueness => true

  def users
    shop_user_groups.map{| u | u.user}
  end
end
