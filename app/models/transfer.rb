class Transfer < ActiveRecord::Base
  attr_accessible :amount, :shop_product, :status, :targeable_id, :targeable_type, :shop_product_id

  belongs_to :targeable, :polymorphic => true
  belongs_to :shop_product

  acts_as_status :status, [:wait, :success, :failer]
  validates :targeable, :presence => true
  validates :shop_product, :presence => true

  validate :valid_status?, :on => :create

  before_validation(:on => :create) do 
    self.status = :wait if status == :invalid    
    change_inventory
  end

  before_validation(:on => :update) do 
    change_status
  end

  private 
  def change_inventory
    update_inventory(amount)
  end

  def change_status
    if changed.include?("status")
      update_inventory(-amount) if status == :failer
    end
  end

  def update_inventory(number)
    shop_product.skip_callback_update(number)        
    unless shop_product.valid?
      shop_product.errors.messages.each do |key, ms|
        errors.add("shop_product", ms.join("<br />"))
      end
    end
  end

  def valid_status?   
    errors.add(:status, "初始化不能使用#{status.name}") if status == :failer
  end
end
