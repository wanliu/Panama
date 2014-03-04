class PersistentChannel < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user

  # delegate :icon, :to => :user

  after_create do
    # TODO： system avatar
    system_avatar = AvatarUploader.new.url
    if channel_type == 1
      user.notify('/friends/add_user', "用户 #{name} 加你为好友", 
        :avatar => icon, 
        :friend_name => name,
        :target => self, 
        :url => "/people/#{name}")
    elsif channel_type == 2
      circle = Circle.find_by_name(name)
      user.notify('/friends/add_quan', "已经添加商圈 #{name} 到好友列表", :avatar => icon, :group_name => name, :target => self, :url => "/communities/#{ circle.id }/circles")
    end

    role = nil
    if 2 == channel_type
      circle = Circle.where(name: name).first
      if circle && circle.is_owner_people?(user)
        role = "Owner"
      end
    end
    CaramalClient.create_persistent_channel(name, user.login, channel_type, role)
  end

  after_destroy do
    system_avatar = AvatarUploader.new.url
    if channel_type == 1
      user.notify('/friends/remove_user', "用户 #{name} 不再是你的好友了", :avatar => icon, :friend_name => name, :target => self, :url => "/people/#{name}")
    elsif channel_type == 2
      user.notify('/friends/remove_quan', "已经从好友列表移除商圈 #{name}", :avatar => icon, :group_name => name, :target => self, :url => "/communities")
    end

    CaramalClient.remove_persistent_channel(name, user.login, channel_type)
  end
end
