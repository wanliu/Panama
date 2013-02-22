class ProductItem < ActiveRecord::Base
  attr_accessible :amount, :price, :product_id, :title, :total, :transaction_id

  belongs_to :cart, inverse_of: :items
  belongs_to :product
  belongs_to :transaction,
             class_name: "OrderTransaction",
             primary_key: 'transaction_id'

  delegate :photos, :to => :product
  delegate :icon, :header, :avatar, :preview, :to => :photos

end
