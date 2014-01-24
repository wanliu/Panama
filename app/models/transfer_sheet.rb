#汇款单
class TransferSheet < ActiveRecord::Base
  attr_accessible :bank, :code, :person, :order_transaction

  belongs_to :order_transaction, inverse_of: :transfer_sheet

  before_validation do
  	self.code = self.code.gsub(' ', '')
  end

  validates :bank, presence: true
  validates :person, presence: true
  validates :order_transaction, presence: true 
  validates :code, presence: true, format: { with: /^\w{6,}$/, message: "请确定汇款单号真实有效" }

  def code_title
  	code.gsub(/(\w{4})/){ "#{$1} " }
  end
end
