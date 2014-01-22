#交易订单状态变更明细
#attributes
#  order_transaction_id: 订单
#  state: 状态
#  expired: 过期
#  expired_state: 是否过期(true有限制, false无限制)
class TransactionStateDetail < ActiveRecord::Base
  attr_accessible :order_transaction, :state, :expired, :count

  belongs_to :order_transaction

  before_create :calculate_expired

  validate :valid_delay_time?

  def calculate_expired
    self.expired = switch_state
  end

  def delay_sign_expired
    expired_time = expired + order_transaction.delay_sign_time
    self.update_attributes({:expired => expired_time, :count => count + 1})    
  end

  private
  def switch_state
    case state
    when "order"
      DateTime.now + 1.day
    when "waiting_transfer"
      DateTime.now + 1.day
    when "waiting_audit_failure"
      DateTime.now + 2.days
    when "waiting_paid"
      DateTime.now + 2.days
    when "waiting_delivery"
      DateTime.now + 3.days
    when "waiting_sign"
      DateTime.now + 10.days
    when "apply_refund"
      DateTime.now + 3.days
    when "refund_failure"
      DateTime.now + 10.days
    when "complete"
      DateTime.now + 15.days
    when "refund"
      DateTime.now + 15.days    
    else
      self.expired_state = false
      DateTime.now
    end
  end

  def valid_delay_time?
    if persisted?
      if changed.include?("expired")
        unless order_transaction.can_delay_sign_expired?
          errors.add(:expired, "请在到期前3天内申请延时!")
        end        
      end
      if changed.include?("count")
        errors.add(:expired, "该订单有已经延长时间了!") if count > 1
      end
    end
  end
end
