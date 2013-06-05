#汇款单
class TransferSheet < ActiveRecord::Base
  attr_accessible :bank, :code, :person, :order_transaction

  belongs_to :order_transaction
end
