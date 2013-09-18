#encoding: utf-8

include CategoryHelper

ActiveAdmin.register Category do
  # actions :index, :edit, :show, :update, :new, :create
  config.clear_action_items!

  action_item do   
    link_to("新增分类", new_plus_system_categories_path) 
  end

  action_item do   
    link_to("热推分类", catalog_index_system_categories_path) 
  end

  action_item :only => :show do   
    link_to("同步属性", all_attach_attributes_system_category_path(params[:id]))
  end



  index do

    div :class => "category_sidebar" do
      render :partial => "tree", :locals => { :root => Category.root }
    end

    column :id
    column :name
    column :ancestry
    column :created_at
    column :properties do |category|
      link_to "#{category.properties.size}个属性", properties_system_category_path(category)
    end
    default_actions
  end

  show do |category|
    div do
      panel("产品 基本属性") do
        attributes_table_for(category) do
          attrbute_names = category.attributes.map { |attr, _| attr }
          attrbute_names.each do |column|
            row column
          end
        end
      end
    end

    div do
      @property = Property.new

      panel("类别 属性") do
        table_for(category.properties, i18n: Property) do
          column :title
          column :name
          column :property_type
        end
      end

      panel("类别 价格选项") do
        table_for(category.price_options, i18n: PriceOption) do
          column :title
          column :name
          column :property
        end
      end
    end

    div do
      @property = Property.new
      active_admin_form_for @property, url: relate_property_system_category_path(params[:id]) do |f|
        f.inputs "属性" do
          f.input :id, label: "属性名", as: :select, :collection => Hash[Property.all.map{|p| [p.title,p.id]}]
        end
        f.buttons
      end
    end

    div do
      @price_option = PriceOption.new
      active_admin_form_for @price_option, url: add_price_options_system_category_path(params[:id]) do |f|
        f.inputs "价格选项" do
          f.input :id, label: "属性名", as: :select, :collection => Hash[Property.all.map{|p| [p.title,p.id]}]
        end
        f.buttons
      end
    end

    class ContentConfig
      include ActiveModel::Validations
      include ActiveModel::Conversion

      attr_accessor :name

      def initialize(hash)
        hash.map { |k,v| send("#{k}=", v) }
      end

      def persisted?
        false
      end

    end

    div do
      contents_config = Rails.application.config.contents
      section = Category.to_s.underscore.to_sym
      panel("类别内容") do
        expects = [:name, :parent, :transfer, :template]
        configs = contents_config[section][:each]
        contents = (configs.keys - expects).map { |k| ContentConfig.new(name: configs[k].name) }
        table_for(contents, i18n: Content) do
          column :name
          column :tool do |row|
            link_to '创建或更改模板',
                    modify_template_system_category_path + "?action_name=#{row.name}"
          end
        end
      end
    end
  end

  member_action :children_table, :method => :get do
    @category = Category.find(params[:id])
    render :layout => false
  end

  member_action :update, :method => :put do
    p = params[:category]
    @category = Category.find(params[:id])
    # @category.update_attributes(params[:category])
    @category.name  = p[:name]
    @category.ancestry = p[:ancestry]
    @category.cover = p[:cover]
    @category.ancestry_depth =  @category.parent.ancestry_depth + 1
    @category.save
    redirect_to system_category_path
  end

  collection_action :new_plus, :title => "新增分类" do
    @category = Category.new
  end


  collection_action :catalog_index, :method => :get do
    @catalog = Catalog.new
    @catalogs = Catalog.all
  end

  # collection_action :new_hot, :title => "热推分类" do
  #   @catalog = Catalog.new
  # end

  collection_action :create_hot, :method => :post do 
    @catalog = Catalog.create(:title => params["catalog"]["title"])
    @catalog.categories << Category.find(params[:parent_id])
    redirect_to catalog_index_system_categories_path
  end



  collection_action :create_plus, :method => :post do
    @category = Category.new(params[:category])
    parent_id = params[:parent_id]
    if parent_id.blank?
      parent_category = Category.root
      @category.ancestry = parent_category.id
      @category.ancestry_depth = parent_category.ancestry_depth + 1
    else
      parent_category = Category.find(parent_id)
      @category.ancestry = "#{parent_category.ancestry}/#{parent_id}"
      @category.ancestry_depth = parent_category.ancestry_depth + 1
    end
    if @category.save
      redirect_to system_category_path(@category)
    else
      render "new_plus"
    end
  end

  member_action :properties, :title => "属性" do
    @category = Category.find(params[:id])
  end

  member_action :price_options do
    @category = Category.find(params[:id])
  end

  member_action :relate_property, :method => :post do
    @category = Category.find(params[:id])
    @category.properties << Property.find(params[:property][:id])
    redirect_to properties_system_category_path(@category)
  end

  member_action :add_price_options, :method => :post do
    @category = Category.find(params[:id])
    @category.price_options.create(:property_id => params[:price_option][:id])
    redirect_to price_options_system_category_path(@category)
  end

  member_action :delete_relation, :method => :put do
    @category = Category.find(params[:id])
    @category.properties.delete(Property.find(params[:property_id]))
    redirect_to properties_system_category_path(@category)
  end

  member_action :comments do
    category = Category.find(params[:id])
  end

  member_action :modify_template do
    @category = Category.find(params[:id])
    @action_name = params[:action_name].to_sym
    @content = PanamaCore::Contents.fetch_for(@category,
                                              @action_name,
                                              :autocreate => true)
    @content.save if @content.new_record?
    @content
  end

  member_action :update_template, :method => :put do
    root = '/panama'.to_dir
    @category = Category.find(params[:id])
    template_name = params[:template][:name]
    @template = Template.find(template_name, root)
    @template.data = params[:template][:data]
    redirect_to system_category_path
  end

  member_action :children_category, :method => :get do
    @category = Category.find(params[:id])
    render :layout => false
  end

  action_item :only => :show do
    link_to '管理属性', properties_system_category_path(params[:id])
  end

  member_action :all_attach_attributes do    
    @category = Category.find(params[:id])
    @category.products.each  do |product|
      product.attach_properties!
      product.save!
    end
    redirect_to system_category_path(params[:id])
  end

end
