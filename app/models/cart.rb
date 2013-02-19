class Cart < ActiveRecord::Base
  attr_accessible :items_count

  belongs_to :user
  has_many :items, inverse_of: :cart, class_name: 'ProductItem', autosave: true  
end
