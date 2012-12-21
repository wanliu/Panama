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
  field :resource_type, type: String
  field :resource_data, type: Moped::BSON::Binary

  def resource
    return nil if resource_type.nil?
    klass = resource_type.classify.constantize
    (@resource = klass.new).load(resource_data)
    @resource
  end

  def resource=(value)
    if value.nil?
      @resource = resource_type = resource_data = nil
    else
      @resource = value
      resource_type = @resource.class.name.underscore
      resource_data = value.dump
    end
  end

  validates :name, presence: true
  validates :template, presence: true

  scope :lookup_name, ->(name){ where(:name => name) }
end
