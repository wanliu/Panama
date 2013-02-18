class ProductItem < ActiveRecord::Base
  attr_accessible :amount, :price, :product_id, :title, :total, :transaction_id
end
