#encoding: utf-8
#describe: 圈子
#
# attributes:
#   name: 名称
#   owner: 所属者(商店与用户)
class Circle < ActiveRecord::Base
  include Graphical::Display
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :name, :owner_id, :owner_type, :description, :city_id, :setting_id, :attachment_id, :setting

  belongs_to :owner, :polymorphic => true

  validates :name, :presence => true
  validates :city_id, :presence => true

  has_many :friends, dependent: :destroy, class_name: "CircleFriends"
  # has_many :receives, dependent: :destroy, class_name: "TopicReceive", as: :receive
  has_many :notifications, as: :targeable, class_name: "Notification", dependent: :destroy
  has_many :categories, dependent: :destroy, class_name: "CircleCategory"
  has_many :topics, dependent: :destroy
  has_many :notice, dependent: :destroy, class_name: "CommunityNotification"
  has_many :invite_users, as: :targeable, dependent: :destroy

  belongs_to :city
  belongs_to :setting, class_name: "CircleSetting"
  belongs_to :attachment

  define_graphical_attr :photos, :handler => :grapical_handler

  validate :valid_name?

  after_create :generate_manage

  # def all_detail
  #   "<h4>分享商圈：<a href='/communities/#{id}/circles'>#{ name}</h4></a><p>简介：#{ description}</p>"
  # end

  #若是Shop类型的circle,就可以看出商店名
  def shop_name
    owner.name if owner_type == "Shop"
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

  def as_json *args
    atts = super *args
    atts[:photos] = photos.attributes
    atts
  end

  def header_url
    photos.header
  end

  def limit_join?
    setting.present? && setting.limit_join
  end

  def limit_city?
    setting.present? && setting.limit_city
  end

  def is_limit_city?(user)
    user = user.is_a?(User) ? user : User.find(user)
    city == user.area
  end

  def address
    return "" if city.nil?
    "#{city.parent.parent.try(:name)}#{city.parent.try(:name)}#{city.name}"
  end

  def to_indexed_json
    options = {
      :name => name,
      :friend_count => friend_count,
      :address => address,
      :description => description,
      :setting => {
        :id => setting.try(:id),
        :limit_city => setting.try(:limit_city),
        :limit_join => setting.try(:limit_join)
      },
      :photos => photos.attributes,
      :owner_type => owner_type,
      :city => {
        :id => city.try(:id),
        :name => city.try(:name)
      },
      :owner => {
        :id => owner.id,
        :photos => owner.photos.attributes
      }            
    }
    options[:owner][:login] = owner.login if owner.is_a?(User)
    if owner.is_a?(Shop)
      options[:owner][:name] = owner.name
      options[:owner][:user] = {
        :id => owner.user.id,
        :login => owner.user.login
      }
    end
    options.to_json
  end

  def friend_users
    friends.joins(:user).map{|f| f.user.as_json }
  end

  def sort_friends
    friends.joins(:user).order("identity asc, created_at desc")
  end

  def top_friends
    sort_friends.limit(40)
  end

  def join_friend(user)
    uid = user.is_a?(User) ? user.id : user
    friends.create_member(uid)

    user
  end

  def is_owner_people?(user)
    user_id = user.is_a?(User) ? user.id : user
    owner_id = owner.is_a?(Shop) ? owner.user.id : owner.id
    if user_id == owner_id
      return true
    else
      return false
    end
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
    uid = user.id
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
