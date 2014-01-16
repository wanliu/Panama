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

  delegate :photos, :login, :to => :user  

  after_create :add_to_persistent_channel


  after_destroy :remove_from_persistent_channel

  def notify_url
    "/communities/#{circle.id}/circles"
  end

  def add_to_persistent_channel
    circle_name = circle.name
    PersistentChannel.where(:user_id => user.id,
                            :name => circle.name,
                            :icon => circle.photos.icon,
                            :channel_type => 2)
                     .first_or_create

    owner = circle.owner
    if owner.is_a?(Shop)
      owner.owner.notify("/circles/joined",
                   "#{user.login} 加入了商圈 #{circle_name}",
                   :target => self,
                   :avatar => user.icon,
                   :user_id => user.id,
                   :url => notify_url)
    elsif owner.is_a?(User)
      owner.notify("/circles/joined",
                   "#{user.login} 加入了个人圈 #{circle_name}",
                   :target => self,
                   :avatar => user.icon,
                   :user_id => user.id,
                   :url => notify_url)
    end
  end

  def remove_from_persistent_channel
    circle_name = circle.name
    PersistentChannel.where(:user_id => user.id,
                            :name => circle_name,
                            :channel_type => 2)
                     .destroy_all

    owner = circle.owner

    if owner.is_a?(Shop)
      owner.owner.notify("/circles/leaved",
                   "#{user.login} 离开了你们的商圈 #{circle_name}",
                   :target => self,
                   :avatar => user.icon,
                   :user_id => user.id,
                   :url => notify_url)
    elsif owner.is_a?(User)
      owner.notify('/circles/leaved', "#{user.login} 离开了个人圈 #{circle_name}",
                   :target => self,
                   :avatar => user.icon,
                   :user_id => user.id,
                   :url => notify_url)

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

  def as_json(*args)
    attas = super *args
    attas["photos"] = photos.attributes
    attas["login"] = login
    attas
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
