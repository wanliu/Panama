class RemoveDeliveryManner < ActiveRecord::Migration
  def change
  	drop_table :delivery_manners
  end
end
