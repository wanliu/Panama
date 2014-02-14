#订单退货原因
class OrderReason < ActiveRecord::Base
  attr_accessible :name

  validates :name, :presence => true, :uniqueness => true
end
