class AddPriceToDeliveryTypes < ActiveRecord::Migration
  def change
  	add_column :delivery_types, :price, :decimal, :precision => 4, :scale => 2
  end
end
