#退货单状态明细
#attributes
#  expired：过期日期
#  expired_state: 过期状态
#  order_refund_id: 退货单
#  state: 状态
class OrderRefundStateDetail < ActiveRecord::Base
  attr_accessible :order_refund_id, :state

  belongs_to :order_refund
  validates :order_refund, :presence => true

  before_create :generate_expired

  def generate_expired
    case state
    when "apply_refund"
      self.expired = DateTime.now + 2.days
    when "waiting_sign"
      self.expired = DateTime.now + 7.days
    when "waiting_delivery"
      self.expired = DateTime.now + 3.days
    when 'apply_failure'
      self.expired = DateTime.now + 3.days
    else
      self.expired_state = false
      self.expired = DateTime.now
    end
  end
end
