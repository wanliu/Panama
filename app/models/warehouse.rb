class Warehouse < ActiveRecord::Base
  include PanamaCore::InventoryCache
  # attr_accessible :title, :body
  has_many :item_in_outs

  def in(*items)
    items.each do |item|
      item_in_outs.create(:product_id      => item.product_id,
                          :product_item_id => item.id,
                          :quantity        => item.amount)
    end
  end

  def out(*items)
    items.each do |item|
      item_in_outs.create(:product_id      => item.product_id,
                          :product_item_id => item.id,
                          :quantity        => -item.amount)
    end
  end

  def inventories(*args)
    self.class.inventories(:conditions => ["IIO.warehouse_id = ?", id])
  end
end
