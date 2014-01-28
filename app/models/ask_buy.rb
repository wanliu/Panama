#encoding: utf-8
class AskBuy < ActiveRecord::Base
  include Graphical::Display
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Tire::Model::UpdateByQuery

  attr_accessible :amount, :describe, :price, :product_id, :status, :title, :open

  belongs_to :product
  belongs_to :user
  has_and_belongs_to_many :attachments
  has_many :comments, :as => :targeable
  has_one :paticipate, :class_name => "AskBuyPaticipate"
  has_many :answer_ask_buys

  validates :user,  :presence => true
  validates :title, :presence => true
  validates :price, :numericality => { :greater_than => 0, :less_than => 9999999 }, :presence => true
  validates :amount, :presence => true, 
            :numericality => { :greater_than => 0, :less_than => 9999999, :only_integer => true }

  define_graphical_attr :photos, :handler => :default_photo

  after_create :init_data

  def default_photo
    if attachments.count > 0
    	attachments.first.file
    else
     	Attachment.new.file
    end
  end

  def answers
    answer_ask_buys.map{|aab| aab.user }
  end

  def close
    update_attributes(:open => false)    
  end

  def init_data
    self.title = "#{self.title}求购"
  end

  def as_json(*args)
    attra = super *args
    attra["user"] = {
      :id => user.id,
      :login => user.login,
      :photos => user.photos.attributes      
    }
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
      :status      => status,
      :created_at  => created_at.strftime("%Y-%m-%d %H:%M:%S"),
      :updated_at  => updated_at,
      :photos      => {
        :icon         => photos.icon,
        :header       => photos.header,
        :avatar       => photos.avatar
      },
      :product => {
        :id => product.try(:id),
        :name => product.try(:name),
        :properties => product.try(:properties_json)
      },
      :open => open
    }.to_json
  end
end
