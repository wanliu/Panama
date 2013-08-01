#encoding: utf-8
#describe: 回复
class Reply < ActiveRecord::Base
  attr_accessible :comment_id, :content, :user_id

  belongs_to :comment
  belongs_to :user

  validates :comment, :presence => true
  validates :user, :presence => true

  validate :validate_user_exists?

  def validate_user_exists?
    errors.add(:user_id, "用户不存！") unless User.exists?(user_id)
  end

  def as_json(*args)
    attrs = super *args
    attrs["user_login"] = user.login
    attrs["user_icon_url"] = user.photos.icon
    attrs
  end

end
