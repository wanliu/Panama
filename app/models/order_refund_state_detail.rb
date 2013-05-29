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
  end
end
