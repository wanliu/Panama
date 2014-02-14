class AddAddressToUserCheckings < ActiveRecord::Migration
  def change
  	remove_column :user_checkings, :company_address
  	add_column :user_checkings, :address_id, :integer
  end
end
