require 'orm_fs'
require 'action_controller/record_identifier'


class Content < ActiveRecord::Base
  attr_accessible :lock, :name, :template
  belongs_to :shop

  has_many :resources
  # field :content_type, type: String
  # field :content_data, type: Moped::BSON::Binary

  validates :name, presence: true
  validates :template, presence: true

  scope :lookup_name, ->(name){ where(:name => name) }


  def resource
    resources.first
  end

  def template
    fs = shop.nil? ? '/'.to_dir : shop.fs
    template = Template.new(super, fs) unless super.nil?
  end

  class << self
    include ActionController::RecordIdentifier

    def fetch_for(resource, name = nil, options = {autocreate: true})
      content_name = dom_id(resource, name)
      cond = { name: content_name }
      @content = if options[:autocreate]
                   where(cond).first_or_initialize(cond)
                 else
                   where(cond).first
                 end
      yield @content if block_given?
      @content
    end
  end

end
