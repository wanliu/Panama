#encoding: utf-8
class ActivitiesOrderTransaction < ActiveRecord::Base

  belongs_to :activity
  belongs_to :order_transaction

  validate :valid_activity?

  def participate
    self.update_attribute(:state, true)
    activity.activities_participates.create(
      :user_id => order_transaction.buyer.id)
  end

  def valid_activity?
    unless activity.valid_expired?
      errors.add(:activity_id, "活动已经过期?")
      false
    else
      true
    end
  end
end