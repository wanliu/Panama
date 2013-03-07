#author: huxinghai
#describe: 提醒

class Notification < ActiveRecord::Base
  attr_accessible :mentionable_id, :mentionable_type, :mentionable_user_id, :user_id

  belongs_to :mentionable, :polymorphic => true
  belongs_to :user
  belongs_to :mentionable_user, :class_name => "User", :foreign_key => "mentionable_user_id"

  def self.create!(options)
    notic = new options
    notic.mentionable = options[:mentionable] if options.key?(:mentionable)
    notic.save!
    notic
  end
end
