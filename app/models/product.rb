# encoding : utf-8
require 'panama_core'

class Product < ActiveRecord::Base
  include Graphical::Display
  include PanamaCore::DynamicProperty
  include PanamaCore::SynchronousProperty
  include PanamaCore::InventoryCache
  # include Redis::Search
  include Tire::Model::Search
  include Tire::Model::Callbacks

  validates :emc13, format: { with: /^\d{13,}$/, message: "请输入真实有效emc13码，只能是13位数字" }

  attr_accessible :description,
                  :name,
                  :price,
                  :summary,
                  :category_id,
                  :shops_category_id,
                  :shop_id,
                  :shop,
                  :default_attachment_id,
                  :attachment_ids,
                  :brand_name,
                  :prices

  attr_accessor :uploader_secure_token, :price_definition

  define_graphical_attr :photos, :handler => :default_photo

  belongs_to :shop                                                                # 所属商店
  belongs_to :category, :autosave => true                                         # 产品类型
  belongs_to :shops_category                                                      # 商店分类
  belongs_to :default_attachment, :class_name => "Attachment"                     # 默认图片
  has_and_belongs_to_many :attachments, :class_name => "Attachment"               # 图片相册
  has_many   :inventory_caches, :class_name => "InventoryCache", :dependent => :destroy                   #
  has_many   :item_in_outs, :dependent => :destroy
  has_many   :comments, :as => :targeable, :dependent => :destroy                                         # 评论
  has_many   :contents, :as => :contentable, :dependent => :destroy                                       # 产品内容配置组
  has_many   :price_options, :as => :optionable, :autosave => true, :dependent => :destroy
  has_many   :shop_products
  has_and_belongs_to_many :properties, :uniq => true do
    def [](name)
      if name.is_a?(String) || name.is_a?(Symbol)
        select { |property| property.name == name.to_s }.first
      else
        super
      end
    end
  end
  has_and_belongs_to_many :property_items, :uniq => true,
           :select => ['property_items.*',
                       'products_property_items.id as products_property_items_id',
                       'products_property_items.title'],
           :autosave => true do
    def [](name)
      property = @association.owner.properties[name]
      select { |pi| pi.property_id == property.id } unless property.nil?
    end

    def set_value_title(value, title)
      val = select { |pi| pi.value == value }.first
      val.title = title
    end
  end
  has_many :properties_values,
           :class_name => "PropertyValue",
           :as         => :valuable,
           :autosave   => true,
           :dependent  => :delete_all do
    def [](property_name)
      property = @association.owner.properties[property_name]
      select { |pv| pv.property_id == property.id }.first unless property.nil?
    end
  end

  # 产品名称搜索
  # redis_search_index(:title_field => :name,
  #                    :score_field => :created_at,
  #                    :prefix_index_enable => true,
  #                    :ext_fields  => [:price])

  def prices_definition
    price_options.map do |po|
      po.property
    end
  end

  # prices[:colour => "red", :sizes => "S"]
  # =>
  has_many :prices, :class_name => "ProductPrice", :autosave => true do
    def [](query_hash)
      owner = @association.owner
      pis = query_hash.map do |k, v|
        pitems = owner.property_items[k]
        pitems.select { |_pi| _pi.value == v }.first unless pitems.blank?
      end || []

      pis -= [nil]
      select { |price| price.items.sort == pis.sort  }.first

    end

    def create(attributes)
      price = attributes.delete(:price)
      pis = build_property_items(attributes)
      super(:property_items => pis, :price => price )
    end

    def build(attributes)
      price = attributes.delete(:price)
      pis = build_property_items(attributes)
      super(:property_items => pis, :price => price)
    end

    private

    def build_property_items(attributes)
      owner = @association.owner
      pis = attributes.map do |k, v|
        pitems = owner.property_items[k]
        pitems.select { |_pi| _pi.value == v }.first unless pitems.blank?
      end || []
      pis -= [nil]
    end
  end

  accepts_nested_attributes_for :prices

  accepts_nested_attributes_for :attachments,
                                :reject_if => proc { |att| att['file_filename'].blank? },
                                :allow_destroy => true

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true
  validates :price, numericality: true

  validates_presence_of :category
  # validates_presence_of :shops_category
  # validates_presence_of :shop

  # delegate :properties, :to => :category, :allow_nil => true

  after_attach_properties do
    price_options.delete_if { true }

    category.price_options.each do |po|
      price_options.target << PriceOption.new(:property => po.property,
                                              :optionable => self,
                                              :name => po.name,
                                              :title => po.title)
    end
  end

  before_save do
    replace_relations price_options
  end

  # Tire 索引结构的 json
  def to_indexed_json
    {
      :name        => name,
      :category_id => category_id,
      :created_at  => created_at,
      :price       => price,
      :shop_id     => shop_id,
      :updated_at  => updated_at,
      :photos      => {
        :icon      => photos.icon,
        :header    => photos.header,
        :avatar    => photos.avatar
      }
    }.to_json
  end

  def default_photo
    default_attachment ? default_attachment.file : Attachment.new.file
  end

  def as_json(*args)
    options = args.extract_options!
    attrs = super *args
    attrs["attachments"] = format_attachment(options[:version_name]) unless options[:only]
    attrs
  end

  def format_attachment(version_name = nil)
    temp, options = [], {version_name: version_name}
    unless default_attachment.blank?
      temp << default_attachment.as_json(options).merge(:default_state => true)
    end
    attachments.each{| atta | temp << atta.as_json(options) }
    temp
  end

  def to_item
    prices
  end

  def update_prices_option(attributes)
    attributes.each do |k, names|
      pp_items = property_items[k]
      additional_ppi = additional_items(pp_items, names)
      subtractive_ppi = subtractive_items(pp_items, names)
      additional_ppi.delete("")
      additional_ppi.map { |name| property_items << properties[k].items.select { |it| it.value == name }.first }
      subtractive_ppi.map { |ppi| property_items.delete(ppi) }
    end
    save!
  end

  def update_prices(attributes)
    attributes.each do |i, attrib|
      price = attrib.delete("price")
      unless price.blank?

        price_item = prices[attrib]
        price_item = prices.create(attrib) if price_item.nil?
        price_item.price = price unless price_item.nil?
      end
    end
    save!
  end


  def additional_items(items, names)
    names.reject { |name| items.select { |it| it.value == name }.first }
  end

  def subtractive_items(items, names)
    items.reject { |item| names.select { |name| name == item.value }.first }
  end

  def category_ancestors_and_self
    if category.nil?
      []
    else
      category.ancestors + [category]
    end
  end
end
