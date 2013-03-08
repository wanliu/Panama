ActiveAdmin.register Product do
  index do
    column :id
    column :name
    column :properties do |product|
    	link_to "Has #{ product.properties.size } properties", properties_system_category_path(product.category)
    end
  end
end