class FileEntity
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Tree

  field :name, type: String
  field :stat, type: String
  field :size, type: Fixnum
  field :data, type: Moped::BSON::Binary

  
end

FileEntity.root || FileEntity.create(:stat => :root)
