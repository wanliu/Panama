class CommunityNotification < ActiveRecord::Base
  attr_accessible :body, :target, :send_user, :circle

  belongs_to :send_user, :class_name => "User"
  belongs_to :target, :polymorphic => true
  belongs_to :circle
end
