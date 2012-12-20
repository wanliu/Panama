class Contents::Article
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :data, type: Moped::BSON::Binary
end
