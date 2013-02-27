class ProductItem < ActiveRecord::Base
  attr_accessible :amount, :price, :product_id, :title, :total, :transaction_id, :cart

  belongs_to :cart, inverse_of: :items, :counter_cache => :items_count
  belongs_to :product
  belongs_to :transaction,
             class_name: "OrderTransaction",
             primary_key: 'transaction_id'

  delegate :photos, :to => :product
  delegate :icon, :header, :avatar, :preview, :to => :photos

  # after_save do |item|
  #   debugger
  #   sum = ProductItem.sum(:amount, :conditions => ["cart_id = ?", item.cart.id])
  #   item.cart.items_count = sum
  #   item.cart.save
  #   self
  # end
end
