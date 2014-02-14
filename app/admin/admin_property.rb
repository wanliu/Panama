#encoding: utf-8
ActiveAdmin.register Property do

  index do
    column :title
    column :name
    column :property_type
    column :items do |property|
      if property.property_type != 'set'
        link_count = "#{property.items.size} 项"
      else
        link_count = link_to("#{property.items.size} 项", items_system_property_path(property))
      end
      link_detail = link_to("详细", system_property_path(property))
      link_delete = link_to("删除", delete_system_property_path(property))
      "#{link_count} #{link_detail} #{link_delete}".html_safe
    end
    # column :user
    # default_actions
  end

  member_action :items, :title => "属性项" do
    @property = Property.find(params[:id])

    # @items = @property.items
  end

  member_action :delete do
    @property = Property.find(params[:id])
    @property.destroy
    redirect_to system_properties_path
  end

  member_action :append_item, :method => :post do
    @property = Property.find(params[:id])
    @property.items << PropertyItem.create(params[:property_item])
    redirect_to items_system_property_path(@property)
  end

  collection_action :search_title do
    title = filter_special_sym(params[:q])
    @items = Property.search2 do
      query do
        boolean do
          must do
            filtered do
              filter :query, :query_string => {
                :query => "title:#{title} OR primitive:#{title}",
                :default_operator => "AND"
              }
            end
          end
        end
      end
    end.results
    respond_to do |format|
      format.json{ render :json => @items }
    end
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :name
      f.input :property_type, :as => :select, :collection => t("property.property_types").invert
    end
    f.buttons
  end
end