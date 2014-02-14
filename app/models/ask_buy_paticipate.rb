#encoding: utf-8
class AskBuyPaticipate < ActiveRecord::Base
  attr_accessible :ask_buy, :shop, :user

  belongs_to :ask_buy
  belongs_to :shop
  belongs_to :user

  validates :ask_buy, :presence => true
  validates :shop, :presence => true
  validates :user, :presence => true


  after_create do
    ask_buy_update_status
    create_transaction
  end

  private
  def create_transaction
    if shop.products.find_by(:id => ask_buy.product_id).nil?
      shop.products.create!(:product_id => ask_buy.product_id)
    end

    order = DirectTransaction.create(
      :buyer_id => ask_buy.user_id,
      :seller_id => shop.id)
    order.items.create(
      :title => "#{ask_buy.title} 求购",
      :shop_id => shop.id,
      :product_id => ask_buy.product_id,
      :price => ask_buy.price,
      :amount => ask_buy.amount,
      :user_id => ask_buy.user_id)
    order.save
  end

  def ask_buy_update_status
    ask_buy.update_attribute(:status, true)
  end
end
