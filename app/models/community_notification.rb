#encoding: utf-8
class CommunityNotification < ActiveRecord::Base
  attr_accessible :body, :target, :send_user, :circle

  belongs_to :send_user, :class_name => "User"
  belongs_to :target, :polymorphic => true
  belongs_to :circle

  after_create do
    url = "/communities/#{id}/notifications/#{c.id}"
    notifications.create!(
      :user_id => send_user.id,
      :mentionable_user_id => owner_member_id,
      :url => url,
      :targeable => self,
      :body => "#{send_user.login}申请加入圈子")
  end

  def owner_member_id
    owner.id_a?(User) ? owner.id : owner.user_id
  end

  def read_notify
    n = Notification.find_by(
      :targeable_id => id,
      :targeable_type => "CommunityNotification")
    n.update_attribute(:read, true) if n.present?
    update_attribute(:state, true)
  end

  def apply_state_title
    return "没有处理"  if apply_state.nil?
    return "同意" if apply_state
    return "拒绝" unless apply_state
  end

  def refuse(user)
    Notification.create!(
      :user_id => user.id,
      :mentionable_user => send_user,
      :body => "#{user.login}拒绝你的加入#{circle.name}圈子",
      :targeable => self)
    self.update_attribute(:apply_state, false)
  end

  def agree(user)
    Notification.create!(
      :user_id => user.id,
      :mentionable_user => send_user,
      :body => "#{user.login}接受你的加入#{circle.name}圈子",
      :targeable => self)
    self.update_attribute(:apply_state, true)
  end
end
