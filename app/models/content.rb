require 'vps'

class Content
  include Mongoid::Document

  field :name, type: String
  field :resource_name, type: String

  def lookup_for(route)

  end

  def template
    File.open(resource_name)
  end
end
