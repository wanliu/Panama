#encoding: utf-8
# describe: 圈子与用户或者商店关系
# attributes:
#   circle_id: 圈子
#   user_id: 用户
class CircleFriends < ActiveRecord::Base
  attr_accessible :circle_id, :user_id, :identity

  belongs_to :circle
  belongs_to :user

  validates_presence_of :circle
  validates_presence_of :user_id
  validates_presence_of :user

  acts_as_status :identity, [:manage, :member]

  validate :valid_some_user_and_circle?
  validate :validate_setting?

  delegate :photos, :to => :user

  def validate_setting?
    if self.circle.setting.try(:limit_city)

      uc = UserChecking.find_by(:owner_id => user_id,
        :owner_type => "User")
      if uc.present? && uc.address.try(:area_id) == circle.city_id
        return true
      else
        errors.add(:area_id, "该圈子不对你所在地区开放!")
        return false
      end
    end
  end

  def self.create_manage(user_id, circle_id = nil)
    options = {user_id: user_id, identity: :manage}
    options[:circle_id] = circle_id if circle_id.present?
    create(options)
  end

  def self.create_member(user_id, circle_id = nil)
    options = {user_id: user_id, identity: :member}
    options[:circle_id] = circle_id if circle_id.present?
    create(options)
  end

  def valid_some_user_and_circle?
    if CircleFriends.exists?(["circle_id=? and user_id=? and id<>?", circle_id, user_id, id.to_s])
      errors.add(:user_id, "已经存在用户了!")
    end
  end

end
