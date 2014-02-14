require 'vfs'

class Mongodb::Content
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Tree
  # include Mongoid::Tree::Traversal
  belongs_to :shop

  field :name, type: String
  field :template, type: String
  field :lock, type: Boolean

  def resource 
    resources.first
  end
  
  embeds_many :resources
  # field :content_type, type: String
  # field :content_data, type: Moped::BSON::Binary

  validates :name, presence: true
  validates :template, presence: true

  scope :lookup_name, ->(name){ where(:name => name) }
end
