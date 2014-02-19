class Transfer < ActiveRecord::Base
  attr_accessible :amount, :shop_product, :status, :targeable_id, :targeable_type, :shop_product_id

  scope :failers, -> { where(:status => _get_state_val(:failer)) }
  scope :completed, -> { where("status<>?", _get_state_val(:failer)) }

  belongs_to :targeable, :polymorphic => true
  belongs_to :shop_product

  acts_as_status :status, [:wait, :success, :failer]
  validates :targeable, :presence => true, on: :save
  validates :shop_product, :presence => true

  validate :valid_status?, :on => :create

  validate :valid_invalid_status?, :valid_modify_ability?, :valid_create_inventory?
  validate :valid_update_inventory?, :on => :update

  before_validation(:on => :create) do 
    self.status = :wait if status == :invalid    
  end

  after_create do 
    change_inventory
  end

  after_update do
    change_status
  end

  def update_success
    self.update_attributes(:status => :success)
  end

  def update_failer
    self.update_attributes(:status => :failer)
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
    if ShopProduct.valid_attribute?(:inventory, number) 
       shop_product.skip_callback_update(number)      
    else
      raise shop_product.errors.messages[:inventory]
    end 
  end

  def valid_status? 
    if status == :failer 
      errors.add(:status, "初始化不能使用#{status.name}状态") 
    end
  end

  def valid_invalid_status?
    if status == :invalid
      errors.add(:status, "不能使用#{status.name}状态") 
    end
  end

  def valid_modify_ability?
    if persisted?
      if changed_attributes["status"] == Transfer._get_state_val(:success)
        errors.add(:status, "该记录已经成功了，不能更改了！")         
      end
    end
  end

  def valid_create_inventory?
    if shop_product.present?
      inventory = shop_product.inventory
      if (inventory + amount) < 0
        errors.add(:shop_product, "#{shop_product.name}库存不足！")
      end
    end
  end

  def valid_update_inventory?
    if status == :failer 
      inventory = shop_product.inventory
      if (inventory + -amount) < 0
        errors.add(:shop_product, "#{shop_product.name}库存不足！")
      end
    end
  end
end

