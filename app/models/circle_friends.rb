#describe: 圈子与用户或者商店关系
class CircleFriends < ActiveRecord::Base
  attr_accessible :circle_id, :friend_id, :friend_type

  belongs_to :circle
  belongs_to :friend, :polymorphic => true
end
