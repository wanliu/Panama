#encoding: utf-8
class CommunityNotification < ActiveRecord::Base
  attr_accessible :body, :target, :send_user, :circle

  belongs_to :send_user, :class_name => "User"
  belongs_to :target, :polymorphic => true
  belongs_to :circle

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
end
