#encoding: utf-8
#describe: 圈子
#
# attributes:
#   name: 名称
#   owner: 所属者(商店与用户)
#   user_id: 操作员
class Circle < ActiveRecord::Base
  attr_accessible :name, :owner_id, :owner_type, :description, :city_id, :setting_id, :created_type

  belongs_to :owner, :polymorphic => true

  validates :name, :presence => true

  has_many :friends, dependent: :destroy, class_name: "CircleFriends"
  has_many :receives, dependent: :destroy, class_name: "TopicReceive", as: :receive
  belongs_to :city
  belongs_to :setting, class_name: "CircleSetting"

  validate :valid_name?

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

  def valid_name?
    if Circle.where("name=? and id<>? and owner_id=? and owner_type=?",
     name, id.to_s, owner_id, owner_type).count > 0
      errors.add(:name, "名称已经存在了！")
    end
  end
end
