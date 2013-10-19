class AddAddressIdToShop < ActiveRecord::Migration
  def change
    add_column :shops, :address_id, :integer
  end
end
