#汇款接收方账户
class TransferAccount < ActiveRecord::Base
  attr_accessible :name, :number, :bank

  belongs_to :bank, inverse_of: :transfer_account

  validates :bank_id, :presence => true, :uniqueness => true

  def self.load_data
    data = YAML::load_file("config/data/transfer_account.yml")["transfer_account"]
    data.each do | d |
      create(d.merge("bank" => Bank.find_by(:code => d["bank"])))
    end
  end
end
