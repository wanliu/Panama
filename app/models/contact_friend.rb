#encoding: utf-8
#describe: 最近联系人
#attribute:
# friend_id: 好友id
# user_id: 用户id
# last_contact_date: 最后一次联系日期
class ContactFriend < ActiveRecord::Base
  attr_accessible :friend_id, :user_id, :last_contact_date

  belongs_to :user
  belongs_to :friend, class_name: "User"

  validates_presence_of :user
  validates_presence_of :friend

  validate :valid_friend?, :valid_friend_and_user?

  def self.join_friend(friend, uid = nil)
    options = {friend_id: friend}
    options[:friend_id] = friend.id if friend.is_a?(User)
    options[:user_id] = uid unless uid.nil?
    cfriend = self.find_by(options)
    if cfriend.nil?
      cfriend = create(options.merge(:last_contact_date => DateTime.now))
    else
      cfriend.update_attribute(:last_contact_date, DateTime.now)
    end
    if cfriend.valid?
      FayeClient.send("/contact_friends/#{cfriend.user_id}",cfriend.as_json)
    end
    cfriend
  end

  def as_json(*args)
    attrs = super *args
    attrs["friend"] = friend.as_json
    attrs
  end

  private
  def valid_friend?
    if ContactFriend.exists?("friend_id=#{friend_id} and user_id=#{user_id} and id<>#{id.to_s}")
      errors.add(:friend_id, "好友已经存在了!")
    end
  end

  def valid_friend_and_user?
    if friend_id == user_id
      errors.add(:friend_id, "不能与自己对话!")
    end
  end
end
