#encoding: utf-8
#describe: 最近联系人
class ContactFriend < ActiveRecord::Base
  attr_accessible :friend_id, :user_id, :last_contact_date

  belongs_to :user
  belongs_to :friend, class_name: "User"

  validates_presence_of :user
  validates_presence_of :friend

  def self.join_friend(friend, uid = nil)
    options = {friend_id: friend}
    options[:friend_id] = friend.id if friend.is_a?(User)
    options[:user_id] = uid unless uid.nil?
    contact_friend = self.find_by(options)
    if contact_friend.nil?
      contact_friend = create(options)
    else
      contact_friend.update_attribute(:last_contact_date, DateTime.now)
    end
    FayeClient.send("/contact_friends/#{contact_friend.user_id}",
      contact_friend.as_json(:include => :friend))
    contact_friend
  end

  # after_create :add_friend_contact
  # def add_friend_contact
  #   ContactFriend.create(
  #     user_id: friend_id,
  #     last_contact_date: DateTime.now,
  #     friend_id: user_id)
  # end

  private
  def valid_friend?
    unless ContactFriend.find_by("friend_id=? and user_id=? and id<>?",friend_id, user_id, id.to_s).nil?
      errors.add(:friend_id, "好友已经存在了!")
    end
  end
end
