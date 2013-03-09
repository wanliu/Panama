#encoding: utf-8
#describe: 评论模型

class Comment < ActiveRecord::Base
  include Extract::Mention

  attr_accessible :content, :user_id, :targeable_id

  belongs_to :user
  belongs_to :targeable, :polymorphic => true
  has_many :replies

  validates :content, :presence => true
  validate :validate_user_exists?, :validate_targeable_exists_and_nil?

  extract_attributes :content

  after_create :notification_user

  def notification_user
    users = content_extract_users
    (users - [user]).each do | u |
      Notification.create!(
        :user_id => u.id,
        :mentionable_user_id => user.id,
        :url => "/activities/#{targeable.id}",
        :body => "在评论，提到你")
    end
  end

  def validate_user_exists?
    errors.add(:user_id, "用户不存在！") unless User.exists?(user_id)
  end

  def validate_targeable_exists_and_nil?
    model = Kernel.const_get(targeable_type) rescue nil
    errors.add(:targeable_type, "模型不存在！") if model.nil?
    targ = model.find(targeable_id) rescue nil
    errors.add(:targeable_id, "#{targeable_type} 不存在！") if targ.nil?
  end

  def self.activity(args)
    create("Activity", args)
  end

  def self.product(args)
    create("Product", args)
  end

  class << self

    private
    def create(type, args)
      comment = new args
      comment.targeable_type = type
      comment.save
      comment
    end
  end
end
