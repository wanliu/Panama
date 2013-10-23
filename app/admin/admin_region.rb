#encoding: utf-8

ActiveAdmin.register Region do
  config.clear_action_items!

  action_item do
    link_to "划分区域", new_plus_system_regions_path
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
      region.region_pictures.map do |picture|
        image_tag picture.photos.icon
      end.join("&nbsp;&nbsp;").html_safe
    end

    column "操作" do |c|
      link_1 = link_to "查看", system_region_path(c), :class =>"member_link"
      link_2 = link_to "编辑", edit_system_region_path(c), :class =>"member_link"
      link_3 = link_to "删除", system_region_path(c), :method => :delete, :confirm => "确定删除吗？", :class =>"member_link"
      link_1 + (link_2 || "") + (link_3 || "")
    end
  end

  collection_action :create do 
    region = Region.create!(:name => params[:region_name])
    params[:part_ids].map { |city_id| RegionCity.create!(:region_id => region.id, :city_id => city_id) }
  end

  collection_action :new_plus, :title => "划分区域" do
    @region = Region.new
    @address = Address.new
  end
end