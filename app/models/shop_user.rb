#encoding: utf-8
# describe: 商店雇员
class ShopUser < ActiveRecord::Base
  attr_accessible :user_id

  belongs_to :user
  belongs_to :shop

  has_many :shop_user_groups, :dependent => :destroy

  validates :user, :presence => true
  validate :valid_user_join_multi_shop?

  after_create  :sync_caramal_create
  after_destroy :sync_caramal_destroy

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

  def sync_caramal_create
    role = shop.user == user ? "Owner" : "Employee"
    CaramalClient.create_shop_employee(shop.name, user.login, role)
  end

  protected

  def sync_caramal_destroy
    role = shop.user == user ? "Owner" : "Employee"
    CaramalClient.remove_shop_employee(shop.name, user.login, role)
  end
end
