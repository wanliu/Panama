# coding: utf-8
class ActivitiesLike < ActiveRecord::Base
  belongs_to :activity
  belongs_to :user
  belongs_to :target, :polymorphic => true

  validates :user, :presence => true
  validates :activity, :presence => true

  validate :valid_activity_already_exists?

  after_create do
    update_activity_like
    notice_user
  end

  def notice_author
    Notification.create!(
      :user_id => user_id,
      :mentionable_user_id => author,
      :url => url,
      :targeable => self,
      :body => "#{user.login}喜欢了你的#{ activity.title}活动")
  end

  def author
    activity.author.id
  end

  after_destroy do
    update_activity_like
  end

  private
  def update_activity_like
    activity.update_like
  end

  def valid_activity_already_exists?
    if ActivitiesLike.exists?(["activity_id=? and user_id=? and id<>?", activity_id, user_id, id.to_s])
      errors.add(:user_id, "该用户已经关注了！")
    end
  end
end