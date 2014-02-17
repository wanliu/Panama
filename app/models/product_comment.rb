class ProductComment < ActiveRecord::Base
  scope :user, ->(user){ where(:user_id => user.id) }
  scope :shop, ->(shop){ where(:shop_id => shop.id) }

  attr_accessible :product_item, :star_logistics, :star_product, :star_service

  belongs_to :product_item
  belongs_to :user
  belongs_to :shop
  has_one :comment, :as => :targeable, :dependent => :destroy

  validates :product_item_id, :uniqueness => true, :presence => true
  validates :shop, :presence => true
  validates :user, :presence => true
  validates :product_id, :presence => true
  
  validate :valid_user?

  before_validation(:on => :create) do
    init_data
  end

  private
  def init_data
    self.shop_id = product_item.shop_id
    self.user_id = product_item.user_id
    self.product_id = product_item.product_id
    self.star_logistics = 5 if self.star_logistics > 5
    self.star_product = 5 if self.star_product > 5
    self.star_service = 5 if self.star_service > 5
  end

  def valid_user?
    unless product_item.user == user
      errors.add(:user_id, "这订单评论不属于你！")
    end
  end

end
