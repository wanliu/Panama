class Product < ActiveRecord::Base
  include Graphical::Display

  attr_accessible :description,
                  :name,
                  :price,
                  :summary,
                  :category_id,
                  :shops_category_id,
                  :shop_id,
                  :shop,
                  :default_attachment_id,
                  :attachment_ids

  attr_accessor :uploader_secure_token

  define_graphical_attr :photos, :handler => :default_photo

  belongs_to :shop
  belongs_to :category, :autosave => true
  belongs_to :shops_category
  belongs_to :default_attachment, :class_name => "Attachment"
  has_and_belongs_to_many :attachments, :class_name => "Attachment"
  has_many :sub_products, :dependent => :destroy
  has_and_belongs_to_many :properties
  has_many :properties_values,
           :class_name => "ProductPropertyValue",
           :autosave => true

  has_many :styles, :dependent => :destroy, :class_name => "StyleGroup" do
    def [](style_name)
      where(:name => style_name.to_s).first
    end
  end

  accepts_nested_attributes_for :attachments,
                                :reject_if => proc { |att| att['file_filename'].blank? },
                                :allow_destroy => true

  validates :name, presence: true
  validates :price, presence: true
  validates :price, numericality: true

  validates_presence_of :category
  validates_presence_of :shops_category
  validates_presence_of :shop

  define_callbacks :category_attribute_changed

  set_callback :category_attribute_changed, :after, :after_category_changed

  # delegate :properties, :to => :category, :allow_nil => true

  def quantity
    sub_products.reduce(0) { |s, i| s + i.quantity }
  end

  def price_range
    range = sub_products.map { |item| item.price }.minmax
    range.first < range.last ? "#{range.first} - #{range.last}" : "#{range.first}"
  end

  def default_photo
    default_attachment ? default_attachment.file : Attachment.new.file
  end

  def format_attachment
    temp = []
    temp << default_attachment.get_attributes.merge(:default_state => true) unless default_attachment.blank?
    attachments.each{| atta | temp << atta.get_attributes }
    temp
  end

  def create_style_subs(params)
    yield if block_given?
    create_style(params[:style])
    create_subs(params[:sub_products])
  end

  def create_style(the_styles)
    the_styles.each_pair do |name, value|
      create_style_group(name, value)
    end unless the_styles.blank?
  end

  def create_style_group(name, value)
    the_group = styles.create!(:name => name)
    value.values.each do |item|
      item = item.dup
      item[:checked] = !item[:checked].blank?
      the_group.items.create!(item)
    end
  end

  def create_subs(subs)
    subs.values.each { |sub| create_sub(sub) } unless subs.blank?
  end

  def create_sub(sub)
    sub = sub.dup
    sub_product = sub_products.create!(:price => sub.delete(:price).to_f,
                                       :quantity => sub.delete(:quantity).to_f)

    build_style_sub_relationship(sub, sub_product)
  end

  def build_style_sub_relationship(sub, sub_product)
    sub.each do |group_name, item_title|
      group_name = group_name.to_s
      group = styles.where(:name => group_name.pluralize).first
      item = group.items.where(:title => item_title).first
      sub_product.items << item
    end
  end

  def update_style_subs(params)
    create_style_subs(params) do
      sub_products.clear
      styles.clear
    end
  end

  def subs_editing(params)
    params[:sub_products]
  end

  def sytles_editing(params)
    params[:style].map do |name, items|
      { 'name' => name, 'items' => items.values }
    end unless params[:style].blank?
  end

  def inventory
    @inventory = InventoryCache
      .where("product_id = ?", id)
      .order("last_time DESC")
      .first_or_create(:product_id => id, :count => 0, :last_time => Time.now.to_f)

    time = @inventory.last_time + 0.0001

    addition_quantity = ItemInOut
      .where("product_id = ? and created_at >= ?", id, Time.at(time))
      .sum("quantity") || 0

    @inventory = if addition_quantity != 0
      InventoryCache.create(:product_id => id,
                            :count => @inventory.count + addition_quantity,
                            :last_time => Time.now.to_f)
    else
      @inventory
    end

    @inventory.count
  end



  after_find do
    delegate_property_setup
  end

  def write_attribute(attr_name, value)
    super
    if attr_name == 'category_id'
      @last_changed_attr = attr_name
      run_callbacks(:category_attribute_changed)
    end
  end

  def property_methods
    @delegate_properties ||= []
  end

  def attach_properties!
    unless category.nil?
      properties.destroy_all
      category.properties.each do |property|
        properties << property
      end
      save
    end
  end

  # def properties
  #   puts 'property'
  #   @properties = super
  #   category.properites.map do |property|
  #     p2 = @properties.select { |p1| p1.name == property.name }.first
  #     p2 = @properties.build(name: property.name, property_type: property.property_type) if p2.nil?
  #   end

  # end

  protected

  def after_category_changed
    old_val, new_val = category_id_change
    delegate_property_setup
  end

  def delegate_property_setup
    @delegate_properties ||= []

    @delegate_properties.each do |method_name|
      @@_delete_method_name = method_name.to_sym
      class << self
        remove_method @@_delete_method_name
      end
    end

    @delegate_properties = []

    properties.each do |property|
      if RUBY_VERSION[/1.9.3/] == "1.9.3"
        name = property.name
        method_name = name
        define_singleton_method(method_name) do
          pv = product_property_values(name)
          pv.value unless pv.nil?
        end
        @delegate_properties << method_name

        define_singleton_method("#{method_name}=") do |other|
          pv = product_property_values(name)
          # conds = { :product_id => id, :property_id => property.id }
          pv = properties_values.create(:product_id => id, :property_id => property.id) if pv.nil?
          pv.value = other
        end
        @delegate_properties << "#{method_name}="
      end
    end
    puts 'setup property ...'
  end

  def product_property_values(name)
    property = properties.where("name = ?", name).first
    properties_values.select { |pv| pv.property.id == property.id }.first
  end
  # def properties_values(name)
  #   properties.select { |property| property.name == name }.first
  # end
  after_save do
    properties_values.each do |value|
      value.save
    end
  end
end
