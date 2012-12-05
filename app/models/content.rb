require 'vfs'

class Content
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Tree
  # include Mongoid::Tree::Traversal
  belongs_to :shop

  field :name, type: String
  field :template, type: String
  field :lock, type: Boolean

  embeds_one :data, :as => :resources

  validates :name, presence: true
  validates :template, presence: true

  scope :lookup_name, ->(name){ where(:name => name) }
end
