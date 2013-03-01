class Product < ActiveRecord::Base
  include Graphical::Display

  attr_accessible :description,
                  :name,
                  :price,
                  :summary,
                  :category_id,
                  :shops_category_id,
                  :shop_id,
                  :default_attachment_id,
                  :attachment_ids

  attr_accessor :uploader_secure_token

  define_graphical_attr :photos, :handler => :default_photo

  belongs_to :shop
  belongs_to :category
  belongs_to :shops_category
  belongs_to :default_attachment, :class_name => "Attachment"
  has_and_belongs_to_many :attachments, :class_name => "Attachment"
  has_many :sub_products, :dependent => :destroy

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

end
