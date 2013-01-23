class ProductItem
  include Mongoid::Document
  include Mongoid::CounterCache

  field :title, type: String
  field :amount, type: BigDecimal
  field :price, type: BigDecimal
  field :total, type: BigDecimal

  belongs_to :cart

  counter_cache :name => 'cart', :field => 'items_count'
end
