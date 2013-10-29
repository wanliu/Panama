#encoding: utf-8
#describe: 圈子
#
# attributes:
#   name: 名称
#   owner: 所属者(商店与用户)
class Circle < ActiveRecord::Base
  include Graphical::Display

  attr_accessible :name, :owner_id, :owner_type, :description, :city_id, :setting_id, :created_type

  belongs_to :owner, :polymorphic => true

  validates :name, :presence => true
  validates :city_id, :presence => true

  has_many :friends, dependent: :destroy, class_name: "CircleFriends"
  has_many :receives, dependent: :destroy, class_name: "TopicReceive", as: :receive
  has_many :notifications, as: :targeable, class_name: "Notification", dependent: :destroy
  has_many :categories, dependent: :destroy, class_name: "CircleCategory"
  belongs_to :city
  belongs_to :setting, class_name: "CircleSetting"
  belongs_to :attachment

  define_graphical_attr :photos, :handler => :grapical_handler

  validate :valid_name?

  after_create do
  end

  def apply_join_notice(sender)
    c = CommunityNotification.create({
      :circle => self,
      :send_user => sender,
      :target => owner,
      :body => "#{sender.login}申请加入圈子#{name}"})
    url = "/shops/#{owner.name}/admins/communities/apply_join/#{c.id}"
    notifications.create!(
      :user_id => sender.id,
      :mentionable_user_id => owner.user_id,
      :url => url,
      :targeable => c,
      :body => c.body)
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

  def friend_count
    friends.count
  end

  def header_url
    photos.header
  end

  def friend_users
    friends.joins(:user).map{|f| f.user.as_json }
  end

  def join_friend(user)
    uid = user
    uid = user.id if user.is_a?(User)
    friends.create_member(user_id: uid)
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
