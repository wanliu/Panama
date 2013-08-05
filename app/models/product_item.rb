class ProductItem < ActiveRecord::Base
  include PanamaCore::DynamicProperty
  include PanamaCore::MemoryAssociation

  attr_accessible :amount, :price, :title, :total, :transaction_id, :cart, :product_id, :product, :shop_id

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
  belongs_to :transaction,
             class_name: "OrderTransaction"
             # primary_key: 'transaction_id'

  belongs_to :shop
  has_one :product_comment

  delegate :photos, :to => :product
  delegate :icon, :header, :avatar, :preview, :to => :photos
  delegate :price_options, :prices_definition, :prices, :to => :product, :allow_nil => true


  memories :properties, :properties_values, :property_items

  before_save do
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
    self.total = self.price * self.amount
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
    super.merge merge_photos(options[:photos])
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

end
