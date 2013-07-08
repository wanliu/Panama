#汇款接收方账户
class TransferAccount < ActiveRecord::Base
  attr_accessible :name, :number, :bank

  belongs_to :bank, inverse_of: :transfer_account
end
