class AddFieldsToUserChecking < ActiveRecord::Migration
  def change
  	# add_column :user_checkings, :count, :integer, :default => 0
  	[:shop_name, :shop_photo, :shop_url, :shop_summary,
     :company_name, :company_address, :company_license, :company_license_photo,
     :ower_name, :ower_photo, :ower_shenfenzheng_number, :phone].each do |field|
     	add_column :user_checkings, field, :string
    end
  end
end
