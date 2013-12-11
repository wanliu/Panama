class PersistentChannel < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user

  after_create do
    # TODO： system avatar
    system_avatar = AvatarUploader.new.url
    if channel_type == 1
      user.notify('/friends/add_user', "用户 #{name} 加你为好友", :avatar => system_avatar)
    elsif channel_type == 2
      user.notify('/friends/add_quan', "商圈 #{name} 加你为友", :avatar => system_avatar)
    end
  end

  after_destroy do
    system_avatar = AvatarUploader.new.url
    if channel_type == 1
      user.notify('/friends/remove_user', "用户 #{name} 不再是你的好友了", :avatar => system_avatar)
    elsif channel_type == 2
      user.notify('/friends/remove_quan', "商圈 #{name} 不再是你的好友了", :avatar => system_avatar)
    end
  end
end
