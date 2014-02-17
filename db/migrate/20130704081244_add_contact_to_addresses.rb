class AddContactToAddresses < ActiveRecord::Migration
  def change
  	add_column :addresses, :contact_name, :string
  	add_column :addresses, :contact_phone, :string
  end
end
