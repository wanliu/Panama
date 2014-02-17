class Mongodb::Product
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Graphical::Display

  attr_accessor :uploader_secure_token
  
  field :name, type: String
  field :price, type: BigDecimal
  field :summary, type: String

  define_graphical_attr :photos, :handler => :default_photo  

  belongs_to :shop
  belongs_to :category
  belongs_to :default_attachment, :class_name => "Attachment", :inverse_of => :default_product
  has_and_belongs_to_many :attachments, :class_name => "Attachment", :inverse_of => :products
    
  accepts_nested_attributes_for :attachments,
                                :reject_if => proc { |att| att['file_filename'].blank? }, 
                                :allow_destroy => true
                                
  validates :name, presence: true
  validates :price, presence: true
  validates :price, numericality: true

  validates_presence_of :category
  validates_presence_of :shop

  def default_photo
    default_attachment.file 
  end

  def format_attachment
    temp = []
    temp << default_attachment.get_attributes.merge(:default_state => true) unless default_attachment.blank? 
    attachments.each{| atta | temp << atta.get_attributes }
    temp 
  end

  after_initialize do 
    if default_attachment.nil?
      build_default_attachment
    end
  end  
end
