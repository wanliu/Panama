#encoding: utf-8
class InviteUser < ActiveRecord::Base
  attr_accessible :body, :read, :send_user_id, :targeable_id, :targeable_type, :user_id, :user, :send_user

  belongs_to :send_user, :class_name => "User"
  belongs_to :user
  belongs_to :targeable, :polymorphic => true

  acts_as_status :behavior, [:agree, :refuse]

  after_create do
    notify_receiver
  end

  def notif_url
    "/communities/#{targeable_id}/invite/#{id}"
  end

  def read_notify
    n = Notification.find_by(
      :targeable_id => id,
      :targeable_type => "InviteUser")
    n.change_read if n.present?
  end

  def agree_join
    self.update_attribute(:behavior, :agree)
    targeable.join_friend(user)
  end

  def refuse_join
    self.update_attribute(:behavior, :refuse)
  end

  private
  def notify_receiver
    # Notification.create!(
    #   :user_id => send_user.id,
    #   :mentionable_user_id => user.id,
    #   :url => '/invite',
    #   :body => "#{send_user.login}邀请你加入#{targeable.name}商圈",
    #   :targeable => targeable
    # )
    user.notify("/invite",
        "#{send_user.login}邀请你加入#{targeable.name}商圈",
        :target => targeable,
        :user_id => send_user.id)
  end
end
