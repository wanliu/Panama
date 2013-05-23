#交易订单状态变更明细
#attributes
#  order_transaction_id: 订单
#  state: 状态
#  expired: 过期
#  expired_state: 是否过期(true有限制, false无限制)
class TransactionStateDetail < ActiveRecord::Base
  attr_accessible :order_transaction, :state, :expired

  belongs_to :order_transaction

  before_create :calculate_expired

  def calculate_expired
    self.expired = switch_state
  end

  private
  def switch_state
    case state
    when "order"
      DateTime.now + 1.minutes
    when "waiting_paid"
      DateTime.now + 2.minutes
    when "waiting_delivery"
      DateTime.now + 3.minutes
    when "waiting_sign"
      DateTime.now + 5.minutes
    when "complete"
      DateTime.now + 10.minutes
    when "refund"
      DateTime.now + 10.minutes
    else
      self.expired_state = false
      DateTime.now
    end
  end

end
