# author: huxinghai
# describe: 商店权限组

class ShopGroup < ActiveRecord::Base
  attr_accessible :name, :shop_id

  belongs_to :shop

  validates :name, :presence => true, :uniqueness => true
end
