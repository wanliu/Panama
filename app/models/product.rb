class Product
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Graphical::Display

  attr_accessor :uploader_secure_token
  
  field :name, type: String
  field :price, type: BigDecimal
<<<<<<< HEAD
  field :summary, type: String 
  
  define_graphical_attr :photos, :handler => :default_photo  
  
=======
  field :summary, type: String

  mount_uploader :preview, ImageUploader

  define_graphical_attr :photos, :handler => :default_image  

  has_many :attachments, :as => :attachable

  accepts_nested_attributes_for :attachments,
                                :reject_if => proc { |att| att['file_filename'].blank? }, 
                                :allow_destroy => true
>>>>>>> chosen_add
  belongs_to :shop
  belongs_to :category
  belongs_to :default_attachment, :class_name => "Attachment", :inverse_of => :default_product
  has_and_belongs_to_many :attachments, :class_name => "Attachment", :inverse_of => :products

  accepts_nested_attributes_for :attachments
  
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
