#describe: 圈子
#
# attributes:
#   name: 名称
#   owner: 所属者(商店与用户)
#   user_id: 操作员
class Circle < ActiveRecord::Base
  attr_accessible :name, :owner_id, :owner_type

  belongs_to :owner, :polymorphic => true

  validates :name, :presence => true

  has_many :friends, dependent: :destroy, class_name: "CircleFriends"
  has_many :receives, dependent: :destroy, class_name: "TopicReceive", as: :receive

  def friend_count
    friends.count
  end

  def join_friend(user)
    uid = user
    uid = user.id if user.is_a?(User)
    friends.create(user_id: uid)
  end
end
