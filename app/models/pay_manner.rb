#付款方式
class PayManner < ActiveRecord::Base
  attr_accessible :desciption, :name

  validates :name, :presence => true, :uniqueness => true
end
