ActiveAdmin.register Property do

  index do
    column :title
    column :name
    column :property_type
    column :items do |property|
      link_to "Has #{property.items.size} items",items_system_property_path(property)
    end
    # column :user
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
end
