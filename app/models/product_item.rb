class ProductItem < ActiveRecord::Base
  attr_accessible :amount, :price, :title, :total, :transaction_id, :cart, :product_id

  belongs_to :cart, inverse_of: :items, :counter_cache => :items_count
  belongs_to :product
  belongs_to :transaction,
             class_name: "OrderTransaction",
             primary_key: 'transaction_id'

  delegate :photos, :to => :product
  delegate :icon, :header, :avatar, :preview, :to => :photos

  # validates :sub_product_id, presence: true

end
