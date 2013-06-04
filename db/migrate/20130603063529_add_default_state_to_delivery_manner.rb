class AddDefaultStateToDeliveryManner < ActiveRecord::Migration
  def change
    add_column :delivery_manners, :default_state, :boolean, :default => false
  end
end
