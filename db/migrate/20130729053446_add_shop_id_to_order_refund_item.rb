class AddShopIdToOrderRefundItem < ActiveRecord::Migration
  def change
    add_column :order_refund_items, :shop_id, :integer
  end
end
