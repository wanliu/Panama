#encoding: utf-8
# describe: 圈子与用户或者商店关系
# attributes:
#   circle_id: 圈子
#   user_id: 用户
class CircleFriends < ActiveRecord::Base
  attr_accessible :circle_id, :user_id

  belongs_to :circle
  belongs_to :user

  validates_presence_of :circle
  validates_presence_of :user_id
  validates_presence_of :user


  validate :valid_some_user_and_circle?
  validate :validate_condition?

  def validate_condition?
    if self.circle.setting.try(:limit_city) == true 
      area_id = UserChecking.joins("right join addresses on addresses.targeable_id = user_checkings.user_id ").where("user_id =? and addresses.area_id<>?",self.user_id, self.circle.city_id).count
      if area_id > 0
        return true
      else
        errors.add(:area_id, "该圈子不对你所在地区开放!")
        return false
      end
    end    
  end

  def valid_some_user_and_circle?
    if CircleFriends.exists?(["circle_id=? and user_id=? and id<>?", circle_id, user_id, id.to_s])
      errors.add(:user_id, "已经存在用户了!")
    end
  end

end
