# coding: utf-8
class ActivitiesLike < ActiveRecord::Base
  belongs_to :activity
  belongs_to :user

  validates :user, :presence => true
  validates :activity, :presence => true

  validate :valid_activity_already_exists?

  after_create do
    update_activity_like
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