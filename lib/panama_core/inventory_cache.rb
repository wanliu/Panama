module PanamaCore
  module InventoryCache

    def inventory
      @inventory = InventoryCache
        .where("product_id = ?", id)
        .order("last_time DESC")
        .first_or_create(:product_id => id, :count => 0, :last_time => Time.now.to_f)

      time = @inventory.last_time + 0.0001

      addition_quantity = ItemInOut
        .where("product_id = ? and created_at >= ?", id, Time.at(time))
        .sum("quantity") || 0

      @inventory = if addition_quantity != 0
        InventoryCache.create(:product_id => id,
                              :count => @inventory.count + addition_quantity,
                              :last_time => Time.now.to_f)
      else
        @inventory
      end

      @inventory.count
    end
  end
end