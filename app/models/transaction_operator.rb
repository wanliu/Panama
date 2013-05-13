#encoding: utf-8
#describe: 订单交易操作员
class TransactionOperator < ActiveRecord::Base
  attr_accessible :operator_id, :order_transaction_id

  belongs_to :operator, class_name: "User"
  belongs_to :order, class_name: "OrderTransaction", foreign_key: "order_transaction_id"

  validates_presence_of :operator
  validates_presence_of :order
end
