class ActivitiesLike < ActiveRecord::Base
  belongs_to :activity
  belongs_to :user

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
end