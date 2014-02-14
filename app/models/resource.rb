class Resource < ActiveRecord::Base
  attr_accessible :content_id, :data, :name

  belongs_to :content
end
