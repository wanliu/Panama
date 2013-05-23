class TradeIncome < ActiveRecord::Base
  attr_accessible :serial_number, :money, :decription, :bank_id, :buyer_id

  belongs_to :buyer, class_name: "User"
  belongs_to :bank, class_name: "Bank"

  # validates :serial_number, :presence => true
  validates :money, :presence => true

  validates_presence_of :buyer
  validates_presence_of :bank_id

  before_create :code_sn

  def code_sn
	self.serial_number = Time.now.strftime("%Y%m%d%H%M%S%4N")
  end
end