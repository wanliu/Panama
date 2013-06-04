#汇款单
class TransferSheet < ActiveRecord::Base
  attr_accessible :bank, :code, :person
end
