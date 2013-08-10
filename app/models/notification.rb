#author: huxinghai
#describe: 提醒

class Notification < ActiveRecord::Base
  scope :unreads, where(:read => false)
  scope :reads, where(:read => true)

  attr_accessible :url, :body, :mentionable_user_id, :user_id

  belongs_to :user
  belongs_to :mentionable_user, :class_name => "User", :foreign_key => "mentionable_user_id"  
  belongs_to :targeable, :polymorphic => true

  validates_presence_of :user
  validates_presence_of :mentionable_user

  after_create :realtime_push_to_client

  def realtime_push_to_client
    count = Notification.unreads.where(user_id: user_id).count
    FayeClient.send("/notification/#{user.login}", {count: count})
  end

  def self.create!(options)
    notic = new options
    notic.save!
    notic
  end
end
