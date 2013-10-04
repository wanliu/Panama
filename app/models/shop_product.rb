#encoding: utf-8
class ShopProduct < ActiveRecord::Base
  acts_as_paranoid
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :shop_id, :product_id, :price, :inventory,:photos,:name

  validates :shop_id, :product_id, presence: true

  belongs_to :shop
  belongs_to :product

  validate :valid_shop_and_product_uniq?

  after_destroy do
    self.index.remove self
  end

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
  delegate :name, :to => :product
  delegate :category, :to => :product

  def as_json(*args)
    attra = super *args
    options = args.extract_options!
    attra["name"] = product.name
    attra["seller"] = shop.as_json
    attra["url"] = product.photos.icon
    attra["product"] = product.as_json(options["version_name"])
    attra["product"]["photo_avatar"] = product.photos.avatar
    attra
  end

  mapping do
    indexes :id, :index => :not_analyzed
    indexes :name, :as => 'product.name'
    indexes :shop_id, :index => :not_analyzed
  end

  private
  def valid_shop_and_product_uniq?
    if ShopProduct.where("shop_id=? and product_id=? and id<>?", shop_id, product_id, id.to_s).first.present?
      errors.add(:product_id, "该商店存在相同的商品了!")
    end
  end
end
