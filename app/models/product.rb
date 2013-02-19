class Product < ActiveRecord::Base
  include Graphical::Display

  attr_accessible :description, :name, :price, :summary, :category_id

  attr_accessor :uploader_secure_token

  define_graphical_attr :photos, :handler => :default_photo  

  has_many :sub_products, :dependent => :destroy
  accepts_nested_attributes_for :sub_products

  has_many :styles, :dependent => :destroy, :class_name => "StyleGroup" do
    def [](style_name)
      where(:name => style_name.to_s).first
    end
  end
  accepts_nested_attributes_for :styles

  belongs_to :shop
  belongs_to :category
  belongs_to :default_attachment, :class_name => "Attachment", :inverse_of => :default_product
  has_and_belongs_to_many :attachments, :class_name => "Attachment"
    
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