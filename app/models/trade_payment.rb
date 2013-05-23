class TradePayment < ActiveRecord::Base
  attr_accessible :serial_number, :money, :decription, :order_transaction_id, :buyer_id

  belongs_to :buyer, class_name: "User"
  belongs_to :order_transaction, class_name: "OrderTransaction"

  validates :serial_number, :presence => true
  validates :money, :presence => true

  validates_presence_of :buyer
  validates_presence_of :order_transaction_id
end
