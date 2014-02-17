#encoding: utf-8
#describe: 订单交易操作员
class TransactionOperator < ActiveRecord::Base
  attr_accessible :operator_id, :order_transaction_id

  belongs_to :operator, class_name: "User"
  belongs_to :order, class_name: "OrderTransaction", foreign_key: "order_transaction_id"

  validates_presence_of :operator
  validates_presence_of :order

  validate :valid_operator?

  after_create do
  	set_current_operator
  end

  def set_current_operator
    order.update_attribute(:operator_id, id)
    order.update_attribute(:operator_state, true)
    order.update_attribute(:dispose_date, DateTime.now)
    order.refunds.update_all(:operator_id => operator_id)
  end

  private

  def valid_operator?
    unless order.seller.is_employees?(operator_id)
      errors.add(:operator_id, "不是#{order.seller.name}的雇员!")
    end
    if order.current_operator.try(:id) == operator_id && new_record?
      errors.add(:operator_id, "#{operator.login}已经是操作员!")
    end
  end

end
