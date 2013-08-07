#encoding: utf-8
class ShopBank < ActiveRecord::Base
  attr_accessible :bank_id, :code, :name, :state

  belongs_to :bank
  belongs_to :shop

  validates :bank, :presence => true
  validates :shop, :presence => true
  validates :name, :presence => true
  validates :code, :presence => true

  validate :valid_shop_and_bank_uniq?

  def valid_shop_and_bank_uniq?
    if ShopBank.where("bank_id=? and shop_id=? and id<>?", bank_id, shop_id, id.to_s).first.present?
      errors.add(:bank_id, "已经存在该银行了！")
    end
  end
end
