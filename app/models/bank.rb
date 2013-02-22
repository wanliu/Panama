class Bank < ActiveRecord::Base
  attr_accessible :code, :name

  validates :name, :presence => true
  validates :code, :presence => true

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
