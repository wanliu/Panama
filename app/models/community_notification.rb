class CommunityNotification < ActiveRecord::Base
  attr_accessible :body, :target, :send_user, :circle

  belongs_to :send_user, :class_name => "User"
  belongs_to :target, :polymorphic => true
  belongs_to :circle

  def read_notify
    n = Notification.find_by(
      :targeable_id => id,
      :targeable_type => "CommunityNotification")
    n.update_attribute(:read, true) if n.parsent?
  end
end
