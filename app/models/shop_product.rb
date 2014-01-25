#encoding: utf-8
class ShopProduct < ActiveRecord::Base
  acts_as_paranoid
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Tire::Model::UpdateByQuery

  attr_accessible :shop_id, :product_id, :price, :inventory,:photos,:name

  validates :shop_id, :product_id, presence: true

  has_many :activities, :dependent => :destroy, :foreign_key => :shop_product_id
  belongs_to :shop
  belongs_to :product
  has_many :answer_ask_buys, :dependent => :destroy
  has_many :transfers
  has_many :adjust_transfers, as: :targeable, dependent: :destroy, class_name: "Transfer"

  validates :price, :numericality => { :greater_than => 0, :less_than => 9999999 }, :presence => true
  validates :inventory, :numericality => { :greater_than_or_equal_to => 0, :less_than => 9999999 }, :presence => true

  validate :valid_shop_and_product_uniq?, :valid_inventory?

  after_destroy do
    self.index.remove self
  end

  before_create do 
    self.inventory = 0 if inventory.nil?
  end

  after_update do
    update_relation_index
  end

  before_save do 
    generate_transfer
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
      :sales => sales,
      :returned => returned,
      :updated_at  => updated_at,
      :photos      => {
        :icon         => product.photos.icon,
        :header       => product.photos.header,
        :avatar       => product.photos.avatar
      },
      :properties => properties_json
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
    attra["photos"] = product.photos.attributes
    attra
  end

  def properties_json
    product.try(:properties_json)
  end

  def update_relation_index
  end

  def no_inventory?
    inventory <= 0
  end

  mapping do
    indexes :id, :index => :not_analyzed
    indexes :name, :as => 'product.name'
    indexes :shop_id, :index => :not_analyzed
  end

  def skip_callback_update(amount)
    self.inventory += amount 
    self.update_column(:inventory, inventory) if valid?
  end

  def recount_inventory
    self.update_column(:inventory, transfers.completed.sum(:amount))
  end

  private
  def valid_shop_and_product_uniq?
    if ShopProduct.exists?([
      "shop_id=? and product_id=? and id<>?", shop_id, product_id, id.to_s])
      errors.add(:product_id, "该商店存在相同的商品了!")
    end
  end

  def valid_inventory?
    errors.add(:inventory, "#{name}库存不足!") if inventory < 0
  end

  def generate_transfer    
    if changed.include?("inventory")
      old_inventory = changed_attributes["inventory"] || 0
      amount = inventory - old_inventory      
      adjust_transfers.create(
        :status => :success,
        :shop_product => self,
        :amount => amount
      ) if amount != 0
    end
  end
end
