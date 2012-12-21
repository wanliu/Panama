class Article
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :data, type: Moped::BSON::Binary

  belongs_to :contents, polymorphic: true
end
