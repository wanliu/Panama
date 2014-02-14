#encoding: utf-8
#describe: 组的好友

class FriendGroupUser < ActiveRecord::Base
  attr_accessible :friend_group_id, :user_id

  belongs_to :friend_group
  belongs_to :user
end
