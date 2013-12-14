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
    like_notice_author
  end

  after_destroy do
    update_activity_like
    unlike_notice_author
  end

  def like_notice_author
    author.notify("/like",
                  "#{user.login} 支持了你的 #{ activity.title} 活动",
                  { :target => self,
                    :avatar => user.icon,
                    :url => "/people/#{user.login}/notifications"})
  end

  def unlike_notice_author
    author.notify("/unlike",
                  "#{user.login} 不再支持你的 #{ activity.title} 活动",
                  { :target => self,
                    :avatar => user.icon,
                    :url => "/people/#{user.login}/notifications"})
  end

  def author
    activity.author
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