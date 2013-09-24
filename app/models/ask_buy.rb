class AskBuy < ActiveRecord::Base
  include Graphical::Display
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :amount, :describe, :price, :product_id, :status, :title

  belongs_to :product
  belongs_to :user
  has_and_belongs_to_many :attachments
  has_many :comments, :as => :targeable
  has_one :paticipate, :class_name => "AskBuyPaticipate"

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
    attra["url"] = photos.default
    attra
  end

  def to_indexed_json
    {
      :title   => title,
      :user => {
        :id        =>  user.id,
        :login     =>  user.login,
        :photos    => {
          :icon      => user.photos.icon,
          :header    => user.photos.header,
          :avatar    => user.photos.avatar
        }
      },
      :product_id  =>  product_id,
      :category    => {
        :id        => product.try(:category).try(:id),
        :name      => product.try(:category).try(:name)
      },
      :describe    => describe,
      :price       => price,
      :amount      => amount,
      :start_time_ms => created_at.to_f,
      :score       => 1,
      :status      => status,
      :created_at  => created_at,
      :updated_at  => updated_at,
      :photos      => {
        :icon         => photos.icon,
        :header       => photos.header,
        :avatar       => photos.avatar
      }
    }.to_json
  end
end
