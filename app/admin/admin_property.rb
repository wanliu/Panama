ActiveAdmin.register Property do

  index do
    column :title
    column :name
    column :property_type
    column :items do |property|
      link_to "#{property.items.size} items",items_system_property_path(property)
    end
    # column :user
    # default_actions
  end

  member_action :items do
    @property = Property.find(params[:id])

    # @items = @property.items
  end

  member_action :append_item, :method => :post do
    @property = Property.find(params[:id])
    @property.items << PropertyItem.create(params[:property_item])
    redirect_to items_system_property_path(@property)
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :name
      f.input :property_type, :as => :select, :collection => %w(string set datetime integer float decimal)
    end
    f.buttons
  end
end