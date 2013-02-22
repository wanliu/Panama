class StyleGroup < ActiveRecord::Base
  attr_accessible :name

  belongs_to :product
  has_many :items, class_name: 'StyleItem', dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :product_id, message: "this stylegroup is exists already now for %{value}" }
  validates :product_id, presence: true
end
