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
    if self.targeable_type == "Activity"
      FayeClient.send("/Activity/un_dispose", {
        type: :new,
        value: format_unread
      })
    else
      count = Notification.unreads.where(user_id: user_id).count
      FayeClient.send("/notification/#{ user.im_token }", {
        count: count, 
        type: targeable_type, 
        value: self
      })
    end
  end

  def self.format_unreads(notifications = [])
    notifications.map do |notification|
      notification.format_unread
    end
  end

  def format_unread
    attra = self.as_json
    if self.targeable_type == "Activity"        
      attra[:targeable] = {
        :id => targeable.id,
        :title => targeable.title,
        :img_url => targeable.photos.avatar
      }
    end
    attra
  end

  def self.create!(options)
    notic = new options
    notic.save!
    notic
  end
end
