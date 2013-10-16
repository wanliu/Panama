#encoding: utf-8
#describe: 圈子
#
# attributes:
#   name: 名称
#   owner: 所属者(商店与用户)
#   user_id: 操作员
class Circle < ActiveRecord::Base
  attr_accessible :name, :owner_id, :owner_type, :description, :city_id, :setting_id, :created_type

  scope :basic, lambda{ where(:created_type => :basic) }
  scope :advance, lambda{ where(:created_type => :advance) }

  belongs_to :owner, :polymorphic => true

  validates :name, :presence => true
  validates :city_id, :presence => true

  has_many :friends, dependent: :destroy, class_name: "CircleFriends"
  has_many :receives, dependent: :destroy, class_name: "TopicReceive", as: :receive
  has_many :notifications, as: :targeable, class_name: "Notification", dependent: :destroy
  belongs_to :city
  belongs_to :setting, class_name: "CircleSetting"

  validate :valid_name?

  def notice_owner(sender, message)
    notifications.create!(
      :user_id => sender.id,
      :mentionable_user_id => owner.id,
      :url => "/shops/#{owner.name}/admins/communities/settings",
      :body => message)
  end

  def friend_count
    friends.count
  end

  def friend_users
    friends.joins(:user).map{|f| f.user.as_json }
  end

  def join_friend(user)
    uid = user
    uid = user.id if user.is_a?(User)
    friends.create(user_id: uid)
  end

  def remove_friend(user)
    uid = user
    uid = user.id if user.is_a?(User)
    friends.find_by(user_id: uid).destroy
  end

  def already_has?(user_id)
    begin
      friends.find(user_id)
    rescue
      false
    end
  end

  def valid_name?
    if Circle.where("name=? and id<>? and owner_id=? and owner_type=?",
     name, id.to_s, owner_id, owner_type).count > 0
      errors.add(:name, "名称已经存在了！")
    end
  end
end
