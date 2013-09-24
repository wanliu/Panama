class ActivitiesParticipate < ActiveRecord::Base
  belongs_to :activity
  belongs_to :user

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
end