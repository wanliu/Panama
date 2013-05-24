#付款
class TradePayment < ActiveRecord::Base
  attr_accessible :money, :decription, :order_transaction

  belongs_to :buyer, class_name: "User"
  belongs_to :order_transaction, class_name: "OrderTransaction"

  # validates :serial_number, :presence => true
  validates :money, :presence => true

  validates :buyer, :presence => true
  validates :order_transaction, :presence => true
  validates :serial_number, :presence => true

  after_create :calculate_money

  before_validation(:on => :create) do
    generate_buyer
    code_sn
  end

  def code_sn
	  self.serial_number = Time.now.strftime("%Y%m%d%H%M%S%4N")
  end

  def generate_buyer
    self.buyer = order_transaction.buyer
  end

  def calculate_money
    buyer.update_attribute(:money, buyer.money - money)
  end
end
