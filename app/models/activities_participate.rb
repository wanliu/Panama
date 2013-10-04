#encoding: utf-8

class ActivitiesParticipate < ActiveRecord::Base
  belongs_to :activity
  belongs_to :user

  validates :user, :presence => true
  validates :activity, :presence => true

  validate :activity_one_user_exists?

  after_create do
    activity_update_participate
  end

  after_destroy do
    activity_update_participate
  end

  private
  def activity_update_participate
    activity.update_participate
  end

  def activity_one_user_exists?
    if ActivitiesParticipate.exists?(
      ["activity_id=? and user_id=? and id<>?", activity_id, user_id, id.to_s])
      errors.add(:user_id, "用户已经参与了?")
    end
  end
end