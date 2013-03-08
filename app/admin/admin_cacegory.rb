ActiveAdmin.register Category do
  index do
    column :id
    column :name
    column :ancestry
    column :created_at
    column :properties do |category|
      link_to "have #{ category.properties.size } propertys", properties_system_category_path(category)
    end
    default_actions
  end

  member_action :properties do
    @category = Category.find(params[:id])
  end

  member_action :relate_property, :method => :post do
    @category = Category.find(params[:id])
    @category.properties << Property.find(params[:property][:id])
    redirect_to properties_system_category_path(@category)
  end

  member_action :delete_relation, :method => :put do
    @category = Category.find(params[:id])
    @category.properties.delete(Property.find(params[:property][:id]))
    redirect_to properties_system_category_path(@category)
  end

  member_action :comments do
    category = Category.find(params[:id])
  end
end