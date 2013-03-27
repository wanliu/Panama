#describe: 圈子
#
# attributes:
# 	name: 名称
#   owner: 所属者(商店与用户)
#   user_id: 操作员
class Circle < ActiveRecord::Base
  attr_accessible :name, :owner_id, :owner_type

  belongs_to :owner, :polymorphic => true

  validates :name, :presence => true

  has_many :friends, dependent: :destroy, class_name: "CircleFriends"

  def friend_count
  	friends.count
  end

  def join_friend(user)
  	uid = user
  	uid = user if user_id.is_a?(User)
  	friends.create(user_id: uid)
  end
end
