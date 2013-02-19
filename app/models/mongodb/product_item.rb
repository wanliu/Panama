class Mongodb::ProductItem
  include Mongoid::Document

  attr_accessible :product, 
                  :title, 
                  :amount, 
                  :price, 
                  :transaction, 
                  :cart, 
                  :product_id,
                  :total


  field :title, type: String
  field :amount, type: BigDecimal
  field :price, type: BigDecimal
  field :total, type: BigDecimal

  belongs_to :product 
  belongs_to :cart, inverse_of: :items, class_name: "Cart"
  belongs_to :transaction, inverse_of: :items, class_name: "Transaction"

  delegate :photos, :to => :product
  delegate :icon, :header, :avatar, :preview, :to => :photos


  # after_create do |document|
  #   cart = document.cart
  #   cart.inc(:items_count, 1)
  # end

  # after_destroy do |document|
  #   cart = document.send
  #   cart.inc(:items_count, -1)
  # end
end
