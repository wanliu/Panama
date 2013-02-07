class Product
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  attr_accessor :uploader_secure_token

  field :name, type: String
  field :price, type: BigDecimal
  field :summary, type: String

  mount_uploader :preview, ImageUploader

  has_many :sub_products, :dependent => :destroy
  accepts_nested_attributes_for :sub_products

  has_many :styles, :dependent => :destroy, :class_name => "StyleGroup" do
    def [](style_name)
      where(:name => style_name.to_s).first
    end
  end


  accepts_nested_attributes_for :styles

  has_many :photos
  belongs_to :shop
  belongs_to :category

  validates :name, presence: true
  validates :price, presence: true
  validates :price, numericality: true

  validates_presence_of :category
  validates_presence_of :shop

end
