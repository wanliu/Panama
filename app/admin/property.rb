ActiveAdmin.register Property do
  index do
    column :title
    column :name
    column :property_type
    # column :items do |property|
    #   link_to "Has #{property.items.size} items",items_system_property_path(property)
    # end
    # column :user
    default_actions
  end

  member_action :items do
  end

  # form do |f|
  #   f.inputs do
  #     f.input :title
  #     f.input :name
  #     f.input :property_type, :as => :select, :collection => %w(string set datetime integer float decimal)
  #     f.semantic_fields_for :items do |items|
  #       items.inputs
  #       # items.buttons
  #     end
  #   end

  #   f.buttons
  # end
end