#encoding: utf-8
#describe: 好友组

class FriendGroup < ActiveRecord::Base
  attr_accessible :name, :user_id

  has_many :friend_group_users
end
