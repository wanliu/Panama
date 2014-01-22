class Transfer < ActiveRecord::Base
  attr_accessible :amount, :shop_product, :status, :targeable_id, :targeable_type, :shop_product_id

  belongs_to :targeable, :polymorphic => true
  belongs_to :shop_product

  acts_as_status :status, [:wait, :success, :failer]

  validate :valid_product_inventory?, :valid_status?, :on => :create

  before_save do 
    change_status
  end

  after_create do 
    change_inventory
  end

  before_validation(:on => :create) do 
    self.status = :wait if status == :invalid
  end

  private  
  def valid_product_inventory?
    errors.add(:amount, "商品库存不足!") if shop_product.inventory + amount < 0 
  end

  def change_inventory
    update_inventory(amount)
  end

  def change_status
    if changed.include?("status")
      update_inventory(-amount) if status == :failer
    end
  end

  def update_inventory(number)
    unless targeable.is_a?(ShopProduct)
      shop_product.inventory += number
      shop_product.save!
    end
  end

  def valid_status?   
    errors.add(:status, "初始化不能使用#{status.name}") if status == :failer
  end
end
