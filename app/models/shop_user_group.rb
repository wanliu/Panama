# describe: 商店雇员组用户
class ShopUserGroup < ActiveRecord::Base
  attr_accessible :shop_group_id, :shop_user_id

  belongs_to :shop_group
  belongs_to :shop_user, :class_name => "ShopsUsers"

  delegate :user, :to => :shop_user
end
