class Mongodb::Resource
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :data, type: Moped::BSON::Binary

  embedded_in :content
end