#encoding: utf-8
#describe: 评论模型

class Comment < ActiveRecord::Base
  include Extract::Mention
  include Convert::Html

  attr_accessible :content, :user_id, :targeable_id

  belongs_to :user
  belongs_to :targeable, :polymorphic => true
  has_many :replies

  validates :content, :presence => true
  validate :validate_user_exists?, :validate_targeable_exists_and_nil?

  extract_attributes :content

  define_format_rule /@(\w{3,20})/ do |mh|
    login = mh[1]
    user = User.find_by(login: login)
    user.nil? ? "@#{login}" : "<a href='/users/#{user.id}'>@#{login}</a>"
  end

  after_save :notification_user
  before_save :convert_html_content

  def convert_html_content
    self.content_html = format_html(self.content)
  end

  def as_json(*args)
    attrs = super *args
    attrs["user_login"] = user.login
    attrs["user_icon_url"] = user.photos.icon
    attrs
  end

  def notification_user
    users = content_extract_users
    (users - [user]).each do | u |
      Notification.create!(
        :user_id => u.id,
        :mentionable_user_id => user.id,
        :url => position_url,
        :body => "在评论，提到你!")
    end
  end

  def position_url
    "/#{targeable.class.to_s.tableize}/#{targeable_id}"
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

  def self.topic(args)
    create("Topic", args)
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
