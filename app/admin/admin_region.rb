# coding: utf-8

ActiveAdmin.register Region do
  config.clear_action_items!

  action_item do
    link_to "添加区域", new_plus_system_regions_path
  end

  index do
    column :id
    column :name
    column "包含城市" do |region|
      region.region_cities.map do |city|
        City.find(city.city_id).try(:name)
      end
    end

    column "城市图片" do |region|
      region.attachments.map do |picture|
        image_tag picture.photos.icon
      end.join("&nbsp;&nbsp;").html_safe
    end

    column "操作" do |region|
      link_edit = link_to "编辑", edit_info_system_region_path(region), :class =>"member_link"
      link_delete = link_to "删除", system_region_path(region), :method => :delete, :confirm => "确定删除区域\"#{region.name}\"吗？", :class =>"member_link"
      (link_edit << " " << link_delete).html_safe
    end
  end

  member_action :edit_info, :method => :get, :title => "编辑" do
    @region = Region.find(params[:id])
  end

  collection_action :create_region, :method => :post do
    begin
      unless params[:region_id ].nil?
        Region.find(params[:region_id]).destroy
      end
      @region = Region.create(:name => params[:region_name],:advertisement => params[:ad])
      unless params[:attachment_ids].nil?
        @region.attachments = params[:attachment_ids].map do |k, v|
          Attachment.find_by(:id => k)
        end.compact
      end
      unless params[:part_ids].nil?
        params[:part_ids].map do |city_id| 
          RegionCity.create(
            :region_id => @region.id, 
            :city_id => city_id) 
          # raise ""  unless region_city.valid?
        end
      end
    rescue Exception => e
      respond_to do |format|
        format.json{ render json: e }
      end
    end
    redirect_to action: :index
  end

  collection_action :get_city, :method => :get do 
    @cities = City.where(:id => params[:part_ids])
    @city = []
    @cities.each do |c|
      unless c.children.blank?
        @city += c.children
      else
        @city << c
      end
    end
    respond_to do |format|
      format.json{ render json: @city }
    end
  end

  collection_action :new_plus, :title => "添加区域" do
    @region = Region.new
    @address = Address.new
  end
end