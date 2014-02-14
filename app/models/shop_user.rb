#encoding: utf-8
# describe: 商店雇员
class ShopUser < ActiveRecord::Base
  attr_accessible :user_id

  belongs_to :user
  belongs_to :shop

  has_many :shop_user_groups, :dependent => :destroy

  validates :user, :presence => true
  validate :valid_user_join_multi_shop?

  def groups
    shop_user_groups.includes(:shop_group).map{|g| g.shop_group }
  end

  def jshop
    shop
  end
  
  def valid_user_join_multi_shop?
    if ShopUser.where("user_id=? and id<>?",
      user_id, id).count > 0
      errors.add(:user_id, "该用户已经加入其它商店!")
    end
  end
end
