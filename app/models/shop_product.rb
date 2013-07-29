class ShopProduct < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :shop_id, :product_id, :price, :inventory

  validates :shop_id, :product_id, presence: true

  belongs_to :shop
  belongs_to :product

  delegate :photos, :to => :product

  def as_json(*args)
    attra = super *args
    attra["name"] = product.name
    attra
  end

  mapping do
    indexes :id, :index => :not_analyzed
    indexes :name, :as => 'product.name'
    indexes :shop_id, :index => :not_analyzed
  end
end
