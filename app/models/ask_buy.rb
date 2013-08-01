class AskBuy < ActiveRecord::Base
  include Graphical::Display
  attr_accessible :amount, :describe, :price, :product_id, :status, :title

  belongs_to :product
  belongs_to :user
  has_and_belongs_to_many :attachments

  validates :user, :presence => true

  define_graphical_attr :photos, :handler => :default_photo

  def default_photo
    if attachments.count > 0
    	attachments.first.file
    else
     	Attachment.new.file
    end
  end
end
