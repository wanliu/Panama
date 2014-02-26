#汇款单
class TransferSheet < ActiveRecord::Base
  attr_accessible :bank, :code, :person, :order_transaction

  belongs_to :order_transaction, inverse_of: :transfer_sheet

  before_validation do
    self.person = self.person.to_s.gsub(' ', '')
    self.code = self.code.to_s.gsub(' ', '')
  end

  validates :bank, presence: true
  validates :order_transaction, presence: true 
  validates :code, presence: true, format: { with: /^\w{6,}$/, message: "请确定汇款单号真实有效" }
  validates :person, presence: true, format: { with: /^[\u4e00-\u9fa5]{2,}$/, message: "请确定汇款人真实有效" }

  def code_title
    code.gsub(/(\w{4})/){ "#{$1} " }
  end
end
