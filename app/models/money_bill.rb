#资金帐目
class MoneyBill < ActiveRecord::Base
  attr_accessible :decription, :money, :owne, :user

  belongs_to :owner, :polymorphic => true
  belongs_to :user

  validates :user, :presence => true
  validates :owner, :presence => true
  validates :serial_number, :presence => true

  before_validation(:on => :create) do
    self.serial_number = Time.now.strftime("%Y%m%d%H%M%S%4N")
  end

  after_create :calculate_money

  def calculate_money
    sql = "update users set money=money+#{money} where id=#{user.id}"
    User.connection.update(sql)
  end
end
