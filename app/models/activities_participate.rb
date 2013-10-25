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

  before_create do
    focus_rebate
  end

  after_destroy do
    activity_update_participate
  end

  private
  def activity_update_participate
    activity.update_participate
  end

  def focus_rebate
    if activity.foucs_type?
      price = activity.focus_spread
      if price > 0
        activity.transactions.each do |t|
          money = price * t.items[0].amount
          t.seller.user.payment(money, t.buyer, "活动聚集返还金额给#{t.buyer.login}买家")
          t.buyer.recharge(money, t.seller, "#{t.seller.name}商家，活动聚集返还金额")
        end
      end
    end
  end

  def activity_one_user_exists?
    if ActivitiesParticipate.exists?(
      ["activity_id=? and user_id=? and id<>?", activity_id, user_id, id.to_s])
      errors.add(:user_id, "用户已经参与了?")
    end
  end
end