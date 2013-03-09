#author: huxinghai
#describe: 提醒

class Notification < ActiveRecord::Base
  scope :unreads, where(:read => false)
  scope :reads, where(:read => true)

  attr_accessible :url, :body, :mentionable_user_id, :user_id

  belongs_to :user
  belongs_to :mentionable_user, :class_name => "User", :foreign_key => "mentionable_user_id"

  def self.create!(options)
    notic = new options
    notic.save!
    notic
  end
end
