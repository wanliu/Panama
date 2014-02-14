#encoding: utf-8
ActiveAdmin.register Product, :title => "商品" do
  config.clear_action_items!
  filter :id
  filter :category
  filter :shop_id
  filter :shops_category_id
  filter :name
  filter :title
  filter :price
  filter :summary
  filter :description
  filter :created_at
  filter :updated_at
  filter :brand_name

  action_item do
    link_to "新增商品", new_plus_system_products_path
  end


  index do
    column :id
    column :name
    column "预览图" do |row|
      image_tag row.photos.header
      # if row.attachments.length > 0
      #   image_tag row.attachments.first.file.url("100x100")
      # end
    end
    column :properties do |product|
      product.attach_properties!
      properties_string = product.properties.map do |prop|
        "#{prop.name}: #{prop.property_type}< #{product.send(prop.name).inspect} >"
      end
      link = link_to "#{product.properties.size}个属性", system_product_path(product)
      link + "   " + properties_string.to_s

    end
    column :action_link do |product|
      link_view = link_to "查看", system_product_path(product)
      link_edit = link_to "修改", edit_plus_system_product_path(product), :class => :member_link
      "#{link_view} #{link_edit}".html_safe
    end
  end

  show do |product|

    div do
      panel("商品基本属性") do
        attributes_table_for(product) do
          attrbute_names = product.attributes.map { |attr, _| attr }
          attrbute_names.delete("default_attachment_id")
          attrbute_names.each do |column|
            row column
          end
          row("关联") do |product|
            output = ActiveSupport::SafeBuffer.new
            attas = product.format_attachment("240x240")
            attas = attas.map do |atta|
              class_name = atta[:default_state] ? :default_preview : :product_preview
              output << content_tag(:img, nil,
                :class => class_name,
                :src => atta[:url])
            end
            output
          end
        end
      end
    end

    div do
      panel("商品属性") do
        attributes_table_for(product) do
          product.attach_properties!
          product.properties.each do |prop|
            row(prop.title) do
              product.send(prop.name)
            end
          end
        end
      end
    end
  end

  collection_action :new_plus, :title => "新增" do
    @product = Product.new
  end

  collection_action :create_plus, :method => :post do
    p = params[:product]
    @product = Product.new(category_id: p[:category_id])
    @product.attach_properties!
    if @product.update_attributes(p.merge(dispose_options(p)))
      redirect_to system_product_path(@product)
    else
      render "new_plus"
    end
  end

  member_action :properties do
    @product = Product.find(params[:id])
  end

  member_action :edit_plus, :title => "编辑" do
    @product = Product.find(params[:id])
    @product.attach_properties!
    category_id = @product[:category_id]
    @product.category_id = category_id unless category_id.nil?
    register_value :form do
      semantic_form_for(@product) do |f|
        break f
      end
    end
    if @product.category.present?
      @content = PanamaCore::Contents.fetch_for(@product.category, :additional_properties_admins)
    end
  end

  member_action :update_plus, :method => :put do
    p = params[:product]
    @product = Product.find(params[:id])
    category_id = p[:category_id]
    @product.category_id = category_id unless category_id.nil?
    @product.attach_properties!
    if @product.update_attributes(p.merge(dispose_options(p)))
      redirect_to system_product_path(@product)
    else
      render "edit_plus"
    end
  end

  member_action :attach_properties, :method => :put do
    @product = Product.find(params[:id])
    @product.attach_properties!
    @product.save!
    redirect_to system_product_path(params[:id])
  end

  action_item :only => :show do
    link_to('关联属性', attach_properties_system_product_path(params[:id]), :method => :put) +
    link_to('编辑属性', edit_plus_system_product_path(params[:id]))
  end

  collection_action :load_category_properties do
    root = '/panama'.to_dir
    # @product = Product.find(params[:id])
    @product = params[:product_id].blank? ? Product.new : Product.find(params[:product_id])

    register_value :form do
      semantic_form_for @product, :method => :put do |f|
        break f
      end
    end
    @category = Category.find(params[:category_id])
    @product.category = @category
    @product.attach_properties!
    # @content = PanamaCore::Contents.fetch_for(@category, :additional_properties_admins)

    # if @content.nil?
    #   render :text => '<h1>暂时没有</h1>'
    # else
    #   render_content(@content, locals: { category: @category })
    # end
    render :layout => false
  end

  def additional_properties_content(category = nil)
    @content = PanamaCore::Contents.fetch_for(category, :additional_properties)
  end
end