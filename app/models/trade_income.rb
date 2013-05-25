class TradeIncome < ActiveRecord::Base
  attr_accessible :money, :decription, :bank_id

  belongs_to :user, class_name: "User"
  belongs_to :bank, class_name: "Bank"

  validates :serial_number, :presence => true
  validates :money, :presence => true

  validates_presence_of :user
  validates_presence_of :bank

  before_validation(:on => :create) do
    code_sn
  end

  after_create :add_money

  def code_sn
    self.serial_number = Time.now.strftime("%Y%m%d%H%M%S%4N")
  end

  def add_money
    sql = "update users set money=money+#{money} where id=#{user.id}"
    User.connection.update(sql)
  end
end