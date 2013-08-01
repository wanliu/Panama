class ShopProduct < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :shop_id, :product_id, :price, :inventory,:photos,:name

  validates :shop_id, :product_id, presence: true

  belongs_to :shop
  belongs_to :product

  # Tire 索引结构的 json
  def to_indexed_json
    {
      :name   => product.name,
      :seller => {
        :id        =>  shop.id,
        :name      =>  shop.name,
        :photos    => {
          :icon      => shop.photos.icon,
          :header    => shop.photos.header,
          :avatar    => shop.photos.avatar
        }
      },
      :product_id  =>  product_id,
      :category    => {
        :id         => product.category.id,
        :name         => product.category.name
      },
      :created_at  => created_at,
      :price       => price,
      :inventory   => inventory,
      :updated_at  => updated_at,
      :photos      => {
        :icon         => product.photos.icon,
        :header       => product.photos.header,
        :avatar       => product.photos.avatar
      }
    }.to_json
  end

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
