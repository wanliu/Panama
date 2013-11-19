class Bank < ActiveRecord::Base
  attr_accessible :code, :name

  has_one :transfer_account, class_name: "TransferAccount"
  has_many :trade_incomes, class_name: "TradeIncome"

  validates :name, :presence => true, :uniqueness => true
  validates :code, :presence => true, :uniqueness => true

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
end
