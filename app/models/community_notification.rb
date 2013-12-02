#encoding: utf-8
class CommunityNotification < ActiveRecord::Base
  attr_accessible :body, :target, :send_user, :circle

  belongs_to :send_user, :class_name => "User"
  belongs_to :target, :polymorphic => true
  belongs_to :circle
  belongs_to :notification

  after_create do
    url = "/communities/#{circle.id}/notifications/#{id}"

    target.notify("/request",
                  " #{send_user.login} 申请加入圈子",
                  :target => circle,
                  :community_id => id)
  end


  #
  # target_member_id 成员 id
  #
  # @deprecated 废弃，直接使用 target 就可以了
  # @return [Fixnum] ID
  def target_member_id
    target.is_a?(User) ? target.id : target.user_id
  end

  def read_notify
    notification.change_read
    update_attribute(:state, true)

  end

  def apply_state_title
    return "没有处理"  if apply_state.nil?
    return "同意" if apply_state
    return "拒绝" unless apply_state
  end

  def refuse(user)
    user.notify("/refuse",
                "#{user.login}拒绝你的加入#{circle.name}圈子",
                :target => circle,
                :community_id => id)

    self.update_attribute(:apply_state, false)
  end

  def agree(user)
    user.notify("/joined",
                "#{user.login}接受你的加入#{circle.name}圈子",
                :target => circle,
                :community_id => id)
    self.update_attribute(:apply_state, true)
  end
end
