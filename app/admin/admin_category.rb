ActiveAdmin.register Category do
  # actions :index, :edit, :show, :update, :new, :create

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
      @property = Property.new

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
      panel("Category Contents") do
        contents = contents_config[section][:each].map { |key, ctnt| ContentConfig.new(:name => ctnt) }
        table_for(contents) do
          column :name
          column :tool do
            link_to 'edit the template', fetch_category_template_system_category_path
          end
        end
      end
    end
  end

  # edit do |category|
  #   div do
  #     @property = Property.new
  #     active_admin_form_for @property, url: relate_property_system_category_path(params[:id]) do |f|
  #       f.inputs "Properties" do
  #         f.input :id, as: :select, collection: Property.all { |property| property.title }
  #       end
  #       f.buttons
  #     end
  #   end
  # end

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

  member_action :fetch_category_template do
    @category = Category.find(params[:id])
    @content = PanamaCore::Contents.fetch_for(@category,
                                              :additional_properties,
                                              :autocreate => true)
    @content.save if @content.new_record?
    @content
  end

  member_action :update_category_template, :method => :put do
    root = '/panama'.to_dir
    @category = Category.find(params[:id])
    # TODO: refactory template
    template_name = params[:template][:name]
    @template = Template.find(template_name)
    @template.data = params[:template][:data]
    redirect_to system_category_path
  end

  action_item :only => :show do
    link_to 'Manager Properties', properties_system_category_path(params[:id])
  end

end

