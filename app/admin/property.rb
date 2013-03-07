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
  end
end