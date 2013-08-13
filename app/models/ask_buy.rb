class AskBuy < ActiveRecord::Base
  include Graphical::Display
  attr_accessible :amount, :describe, :price, :product_id, :status, :title

  belongs_to :product
  belongs_to :user
  has_and_belongs_to_many :attachments
  has_many :comments, :as => :targeable

  validates :user, :presence => true
  validates :title, :presence => true
  validates :price, :numericality => true
  validates :amount, :presence => true, :numericality => { :greater_than => 0 }


  define_graphical_attr :photos, :handler => :default_photo

  def default_photo
    if attachments.count > 0
    	attachments.first.file
    else
     	Attachment.new.file
    end
  end

  def as_json(*args)
    attra = super *args
    attra["user"] = user.as_json
    attra["url"] = photos.preview
    attra
  end
end
