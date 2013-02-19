class Mongodb::Activity
  include Mongoid::Document

  field :url, type: String
end
