#encoding: utf-8
#describe: 圈子
#
# attributes:
#   name: 名称
#   owner: 所属者(商店与用户)
class Circle < ActiveRecord::Base
  include Graphical::Display

  attr_accessible :name, :owner_id, :owner_type, :description, :city_id, :setting_id, :attachment_id

  belongs_to :owner, :polymorphic => true

  validates :name, :presence => true
  validates :city_id, :presence => true

  has_many :friends, dependent: :destroy, class_name: "CircleFriends"
  has_many :receives, dependent: :destroy, class_name: "TopicReceive", as: :receive
  has_many :notifications, as: :targeable, class_name: "Notification", dependent: :destroy
  has_many :categories, dependent: :destroy, class_name: "CircleCategory"
  has_many :topics, dependent: :destroy
  has_many :notice, dependent: :destroy, class_name: "CommunityNotification"

  belongs_to :city
  belongs_to :setting, class_name: "CircleSetting"
  belongs_to :attachment

  define_graphical_attr :photos, :handler => :grapical_handler

  validate :valid_name?

  after_create do
    generate_manage
  end

  def apply_join_notice(sender)
    notice.create(
      :send_user => sender,
      :target => owner
    )
  end

  def notice_exists?(send_user)
    user_id = sender_user.is_a?(User) ? sender_user.id : sender_user
    notice.exists?(:send_user_id => user_id, :state => false)
  end

  def user_notice(sender_user)
    user_id = sender_user.is_a?(User) ? sender_user.id : sender_user
    notice.find_by(:send_user_id => user_id, :state => false)
  end

  def grapical_handler
    (attachment.nil? ? Attachment.new : attachment).file
  end

  def generate_manage
    user_id = owner.is_a?(Shop) ? owner.user_id : owner.id
    unless friends.exists?(:user_id => user_id)
      friends.create_manage(user_id)
    end
  end

  def owner_title
    owner.is_a?(Shop) ? "商家" : "个人"
  end

  def friend_count
    friends.count
  end

  def header_url
    photos.header
  end

  def limit_join?
    setting.present? && (setting.limit_join || setting.limit_city)
  end

  def address
    return "" if city.nil?
    "#{city.parent.parent.try(:name)}#{city.parent.try(:name)}#{city.name}"
  end

  def friend_users
    friends.joins(:user).map{|f| f.user.as_json }
  end

  def join_friend(user)
    uid = user.is_a?(User) ? user.id : user
    friends.create_member(uid)
  end

  def is_manage?(user)
    user_id = user.is_a?(User) ? user.id : user
    status = CircleFriends._get_state_val(:manage)
    friends.exists?(:user_id => user_id, :identity => status)
  end

  def is_member?(user)
    user_id = user.is_a?(User) ? user.id : user
    friends.exists?(:user_id => user_id)
  end

  def remove_friend(user)
    uid = user
    uid = user.id if user.is_a?(User)
    friends.find_by(user_id: uid).destroy
  end

  def already_has?(user_id)
    friends.exists?(["user_id=?", user_id])
  end

  def valid_name?
    if Circle.exists?(["name=? and id<>? and owner_id=? and owner_type=?",
     name, id.to_s, owner_id, owner_type])
      errors.add(:name, "名称已经存在了！")
    end
  end
end
