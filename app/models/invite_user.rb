#encoding: utf-8
class InviteUser < ActiveRecord::Base
  attr_accessible :body, :read, :send_user_id, :targeable_id, :targeable_type, :user_id, :user, :send_user

  belongs_to :send_user, :class_name => "User"
  belongs_to :user
  belongs_to :targeable, :polymorphic => true

  validates :send_user, :presence => true
  validates :user, :presence => true
  validates :targeable, :presence => true

  acts_as_status :behavior, [:agree, :refuse]

  after_create :notify_receiver

  def read_notify
    n = Notification.find_by(
      :targeable_id => id,
      :targeable_type => "InviteUser")
    n.change_read if n.present?
  end

  def agree_join
    self.update_attribute(:behavior, :agree)    
  end

  def refuse_join
    self.update_attribute(:behavior, :refuse)
  end

  def self.find_by_update(id)
    invite = find(id)
    invite.update_attribute(:read, true)
    invite
  end

  private
  def notify_receiver
    if targeable_type == "Circle"
      user.notify("/circles/invite",
          "#{send_user.login}邀请你加入商圈 #{targeable.name}",
          :target => targeable,
          :user_id => send_user.id,
          :invite => self,
          :group_name => targeable.name,
          :url => notify_url)
    elsif targeable_type == "Shop"
      user.notify("/employees/invite",
        "商店 #{targeable.name} 邀请你加入",
        :target => targeable,
        :avatar => user.icon,
        :url => "/people/#{user.login}/invite/#{id}")
    end
  end

  def notify_url
    "/communities/#{targeable_id}/invite/#{id}"
  end
end
