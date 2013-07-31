class ProductComment < ActiveRecord::Base
  attr_accessible :product_item, :star_logistics, :star_product, :star_service

  belongs_to :product_item
  has_many :comments, :as => :targeable, :dependent => :destroy

  before_create :init_data

  private
  def init_data
    self.shop_id = product_item.shop_id
    self.user_id = product_item.user_id
    self.star_logistics = 5 if self.star_logistics > 5
    self.star_product = 5 if self.star_product > 5
    self.star_service = 5 if self.star_service > 5
  end
end
