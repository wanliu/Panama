#encoding: utf-8
class ProductItem < ActiveRecord::Base
  include PanamaCore::DynamicProperty
  include PanamaCore::MemoryAssociation

  attr_accessible :amount, :price, :title, :total, :owner, :cart, :product_id, :product, :shop_id, :user_id, :buy_state

  attr_accessor :options

  cattr_accessor :product_options
  @@product_options = {}

  has_and_belongs_to_many   :properties do
      def [](name)
      if name.is_a?(String) || name.is_a?(Symbol)
        select { |property| property.name == name.to_s }.first
      else
        super
      end
    end
  end
  has_many                  :properties_values,
                            :class_name => "PropertyValue",
                            :as         => :valuable,
                            :autosave   => true,
                            :dependent  => :delete_all do
    def [](property_name)
      property = @association.owner.properties[property_name]
      select { |pv| pv.property.id == property.id }.first
    end
  end

  has_and_belongs_to_many   :property_items,
                            # :select => ['property_items.*',
                            #             'product_items_property_items.id as products_items_property_items_id',
                            #             'product_items_property_items.title'],
                            :autosave => true do
    def [](name)
      property = @association.owner.properties[name]
      select { |pi| pi.property.id == property.id }
    end

    def set_value_title(value, title)
      val = select { |pi| pi.value == value }.first
      val.title = title
    end
  end


  belongs_to :cart, inverse_of: :items, :counter_cache => :items_count
  belongs_to :product
  belongs_to :user
  belongs_to :owner, :polymorphic => true
             # primary_key: 'transaction_id'

  belongs_to :shop
  has_one :product_comment

  delegate :photos, :to => :product
  delegate :icon, :header, :avatar, :preview, :to => :photos
  delegate :price_options, :prices_definition, :prices, :to => :product, :allow_nil => true

  #购买方式 direct: 直接购买 guarantee: 担保
  acts_as_status :buy_state, [:direct, :guarantee]

  memories :properties, :properties_values, :property_items

  validates :user, :presence => true
  validates :shop, :presence => true
  validates :product, :presence => true
  validates :price, :numericality => true

  validates :amount, :presence => true, 
            :numericality => { :only_integer => false, :greater_than_or_equal_to => 1 }
  validates :total, :presence => true,
            :numericality => { :greater_than => 0 }

  validate :valid_buyer_self_product?

  after_initialize do
    update_total
  end

  after_create do
    if product.present? && !@product_options.blank?
      product.prices_definition.each do |prop|
        properties << prop
      end

      property_items = product.property_items

      delegate_property_setup

      price_options.each do |option|
        option_name = option.name.to_sym
        send("#{option_name}=", @product_options[option_name])
      end
      save!
    end
  end

  def update_total    
    unless amount.nil? || price.nil?
      self.total = self.price * self.amount
    end
  end

  def shop_product
    ShopProduct.find_by(
      :shop_id => shop_id, 
      :product_id => product_id)
  end

  def options
    super || properties_values.map { |prop| prop.value }.join('/')
  end

  def initialize(attributes = nil, options = {}, &block)
    if attributes && attributes.is_a?(Hash)
      @product_options = (attributes.delete(:options) || {}).symbolize_keys
    end

    super
  end

  def as_json(options = {})
    attrs = super.merge merge_photos(options[:photos])
  end

  def merge_photos(options = nil)
    keys = case options
           when Symbol, String
             [options]
           when Array
             options
           when NilClass
             photos.options[:allow]
           else
             photos.options[:allow]
           end

    Hash[keys.map { |k| [k, photos.send(k) ]}]
  end

  private
  def valid_buyer_self_product?
    errors.add(:shop, "不能购买自己的商品！") if user == shop.user
  end
end
