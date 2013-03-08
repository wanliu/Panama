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

  show do |category|
    div do
      panel("Product Base") do
        attributes_table_for(category) do
          attrbute_names = category.attributes.map { |attr, _| attr }
          attrbute_names.each do |column|
            row column
          end
        end
      end
    end

    div do
      panel("Category Properties") do
        table_for(category.properties) do
          column :name
          column :property_type
        end
      end
    end

    div do
      @property = Property.new
      active_admin_form_for @property, url: relate_property_system_category_path(params[:id]) do |f|
        f.inputs "Properties" do
          f.input :id, as: :select, collection: Property.all { |property| property.title }
        end
        f.buttons
      end
    end
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

  action_item :only => :show do
    link_to 'Manager Properties', properties_system_category_path(params[:id])
  end
end