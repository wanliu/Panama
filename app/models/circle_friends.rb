#encoding: utf-8
# describe: 圈子与用户或者商店关系
# attributes:
#   circle_id: 圈子
#   friend: 商店或者用户
class CircleFriends < ActiveRecord::Base
  attr_accessible :circle_id, :user_id

  belongs_to :circle
  belongs_to :user

  validates_presence_of :circle
  validates_presence_of :user_id

  validate :valid_some_user_and_circle?

  def valid_some_user_and_circle?
  	errors.add(:user_id, "已经存在用户了!") if exists?("circle_id=? and user_id=? and id<>'?'", circle_id, user_id, id)
  end

end
