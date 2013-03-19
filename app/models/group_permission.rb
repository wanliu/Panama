# describe: 组与权限关系

class GroupPermission < ActiveRecord::Base
  attr_accessible :group_id, :permission_id

  belongs_to :group ,:class_name => "ShopGroup"
  belongs_to :permission

end
