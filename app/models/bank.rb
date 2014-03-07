class Bank < ActiveRecord::Base
  attr_accessible :code, :name

  has_one :transfer_account, class_name: "TransferAccount"
  has_many :trade_incomes, class_name: "TradeIncome"

  validates :name, presence: true, uniqueness: true, format: { with: /^[\u4e00-\u9fa5]{2,}$/, message: "请确定开户人真实有效，不能重复" }
  validates :code, presence: true, uniqueness: true, format: { with: /^\d{13,19}$/, message: "请确定银行卡号真实有效，13-19位数字" }

  before_validation do
    self.name = self.name.to_s.gsub(' ', '')
    self.code = self.code.to_s.gsub(' ', '')
  end

  def self.load_file(file)
    config_root = YAML.load_file(file)["bank"]
    load_config(config_root)
  end

  def self.load_config(banks)
    banks.each do |bank|
      bank_attribute = bank.values[0]
      Bank.create bank_attribute
    end
  end

  def code_title
    code.gsub(/(\w{4})/){ "#{$1} " }
  end
end
