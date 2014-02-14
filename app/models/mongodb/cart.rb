
class Mongodb::Cart
  include Mongoid::Document
  include Mongoid::Timestamps

  field :items_count, :type => Integer, :default => 0

  belongs_to :user
  has_many :items, inverse_of: :cart, class_name: 'ProductItem', autosave: true

end
