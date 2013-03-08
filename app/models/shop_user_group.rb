# describe: 商店雇员组
class ShopUserGroup < ActiveRecord::Base
  attr_accessible :shop_group_id, :user_id

  belongs_to :shop_group
  belongs_to :user

  validates :user
  validates :shop_group
end
