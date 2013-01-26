class Product
  include Mongoid::Document
  include Mongoid::Timestamps::Created 
  include Graphical::Display 

  define_graphical_attr :photos, :handler => :default_photo, :allow => [:ico, :avatar, :img]

  configrue_graphical :ico => "20x20", :avatar => "120x90", :img => "250x187"

  attr_accessor :uploader_secure_token
  
  field :name, type: String
  field :price, type: BigDecimal
  field :summary, type: String 

  has_and_belongs_to_many :attachments, :class_name => "Attachment", :inverse_of => :products

  accepts_nested_attributes_for :attachments
  
  belongs_to :shop
  belongs_to :category
  belongs_to :default_attachment, :class_name => "Attachment", :inverse_of => :default_product
  
  validates :name, presence: true
  validates :price, presence: true
  validates :price, numericality: true

  validates_presence_of :category
  validates_presence_of :shop

  def default_photo
    default_attachment.attachable
  end

  def format_attachment
    attachments.map do | atta |
      atta.get_attributes
    end
  end
end
