ActiveAdmin.register Shop do
	filter :address, :collection => proc { DeliveryAddress.all.map(&:location) }
	filter :user
	filter :name
	filter :actived
	filter :shop_url
	filter :shop_summary

  index do
    column :id
    column :name
    column :user
    column :actived
  end
end