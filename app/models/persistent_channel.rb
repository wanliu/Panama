class PersistentChannel < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user

  after_create do
    if channel_type == 1
      user.notify('add_friend_user', "用户 #{name} 加你为好友")
    elsif channel_type == 2
      user.notify('add_friend_quan', "商圈 #{name} 加你为友")
    end
  end

  after_destroy do
    if channel_type == 1
      user.notify('remove_friend_user', "用户 #{name} 不再是你的好友了")
    elsif channel_type == 2
      user.notify('remove_friend_quan', "商圈 #{name} 不再是你的好友了")
    end
  end
end
