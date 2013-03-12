require 'vfs'
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

  class << self
    include ActionController::RecordIdentifier

    def fetch_for(resource, name = nil)
      content_name = dom_id(resource, name)
      conds = { name: content_name, template: "templates/#{content_name}.html.erb" }
      where(conds).first_or_create(conds)
    end
  end

end
