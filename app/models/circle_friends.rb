#encoding: utf-8
# describe: 圈子与用户或者商店关系
# attributes:
#   circle_id: 圈子
#   user_id: 用户
class CircleFriends < ActiveRecord::Base
  attr_accessible :circle_id, :user_id, :identity

  belongs_to :circle
  belongs_to :user

  validates :user, :presence => true
  validates :circle, :presence => true

  acts_as_status :identity, [:manage, :member]

  validate :valid_some_user_and_circle?

  delegate :photos, :to => :user

  after_create :add_to_persistent_channel


  after_destroy :remove_from_persistent_channel

  def add_to_persistent_channel
    circle_name = circle.name
    PersistentChannel.where(:user_id => user.id,
                            :name => circle.name,
                            :icon => circle.photos.icon,
                            :channel_type => 2)
                     .first_or_create

    owner = circle.owner

    # user.notify('/joined', "恭喜你成功加入圈子 #{name}")
    if owner.is_a?(Shop)
      owner.notify("/joined",
                   "#{user.login} 加入了圈子 #{circle_name}",
                   :target => self,
                   :avatar => user.icon,
                   :user_id => user.id)
    elsif owner.is_a?(User)
      owner.notify("/joined",
                   "#{user.login} 加入了圈子 #{circle_name}",
                   :target => self,
                   :avatar => user.icon,
                   :user_id => user.id)
    end
  end

  def remove_from_persistent_channel
    circle_name = circle.name
    PersistentChannel.where(:user_id => user.id,
                            :channel_type => 2)
                     .destroy_all

    owner = circle.owner

    if owner.is_a?(Shop)
      owner.notify("/leaved",
                   "#{user.login}  已经离开了你们的商圈 #{circle_name}",
                   :target => self,
                   :avatar => user.icon,
                   :user_id => user.id)
    elsif owner.is_a?(User)
      owner.notify('/leaved', "#{user.login} 已经离开了您的商圈 #{circle_name}",
                   :target => self,
                   :avatar => user.icon,
                   :user_id => user.id)

    end
  end

  def validate_setting?
    if self.circle.setting.try(:limit_city)

      uc = UserChecking.find_by(:user_id => user_id)
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

  def manage?
    self.identity == :manage
  end

  def identity_title
    I18n.t("circle_friend.identity.#{identity.name}")
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
