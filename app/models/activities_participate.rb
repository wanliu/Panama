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

  #修改未付款订单的价格（当活动进行到下一阶段时）
  def change_price_for_old_order(price)
    transactions = ActivitiesOrderTransaction.where(:activity_id => activity.id, :state => false).includes(:order_transaction)
    transactions.each do |t|
      t.order_transaction.items.each do |i|
        if i.shop_product.id == activity.shop_product.id
          i.update_attributes(:price => price)
        end
      end
    end
  end

  def focus_rebate
    if activity.foucs_type?
      price = activity.focus_spread
      change_price_for_old_order(activity.focus_price)
      activity.transactions.each do |t| 
        unless t.items[0].price == activity.focus_price
          money = price * t.items[0].amount
          t.seller.user.payment(money, {
            :target => t.buyer,
            :owner => t,
            :decription => "活动聚集返还金额给#{t.buyer.login}买家"}) 
        end       
      end if price > 0
    end
  end

  def activity_one_user_exists?
    if ActivitiesParticipate.exists?(
      ["activity_id=? and user_id=? and id<>?", activity_id, user_id, id.to_s])
      errors.add(:user_id, "用户已经参与了?")
    end
  end
end