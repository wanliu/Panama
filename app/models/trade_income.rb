class TradeIncome < ActiveRecord::Base
  attr_accessible :serial_number, :money, :decription, :bank_id, :buyer_id

  belongs_to :buyer, class_name: "User"
  belongs_to :bank, class_name: "Bank"

  validates :serial_number, :presence => true
  validates :money, :presence => true

  validates_presence_of :buyer
  validates_presence_of :bank_id

end
