class ProductItem
  include Mongoid::Document

  attr_accessible :product, :title, :amount, :price


  field :title, type: String
  field :amount, type: BigDecimal
  field :price, type: BigDecimal
  field :total, type: BigDecimal

  belongs_to :product 
  belongs_to :cart

  def icon
    product.preview.url("30x30")
  end

  after_create do |document|
    cart = document.cart
    cart.inc(:items_count, 1)
  end

  after_destroy do |document|
    cart = document.send
    cart.inc(:items_count, -1)
  end
end
