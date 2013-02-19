require 'vfs'

class Content < ActiveRecord::Base
  attr_accessible :lock, :name, :template
  belongs_to :shop

  def resource 
    resources.first
  end
  
  has_many :resources
  # field :content_type, type: String
  # field :content_data, type: Moped::BSON::Binary

  validates :name, presence: true
  validates :template, presence: true

  scope :lookup_name, ->(name){ where(:name => name) }  
end
