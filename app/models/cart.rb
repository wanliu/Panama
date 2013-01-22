
class Cart
  include Mongoid::Document
  include Mongoid::Timestamps

  field :items_count, :type => Integer, :default => 0

  belongs_to :user
  has_many :product_items
  
end
