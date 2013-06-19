#encoding: utf-8

ActiveAdmin.register Product do
  config.clear_action_items!

  action_item do
    link_to "新增 Product", new_plus_system_products_path
  end


  index do
    column :name
    column :properties do |product|
      properties_string = product.properties.map do |prop|
        "#{prop.name}: #{prop.property_type}< #{product.send(prop.name).inspect} >"
      end
      link = link_to "have #{ product.properties.size } propertys.", system_product_path(product)
      link + "   " + properties_string.to_s

    end
    column do |product|
      link_to "修改", edit_plus_system_product_path(product)
    end
  end

  show do |product|
    div do
      panel("Product Base") do
        attributes_table_for(product) do
          attrbute_names = product.attributes.map { |attr, _| attr }
          attrbute_names.each do |column|
            row column
          end
        end
      end
    end

    div do
      panel("Product Properties") do
        attributes_table_for(product) do
          property_names = product.properties.map { |prop, _| prop.name }
          property_names.each do |column|
            row column
          end
        end
      end
    end
  end

  collection_action :new_plus do
    @product = Product.new
  end

  collection_action :create_plus, :method => :post do
    p = params[:product]
    @product = Product.new(p)
    @product.attachment_ids = dispose_options(p)[:attachment_ids]
    if @product.save
      redirect_to system_product_path(@product)
    end
  end

  member_action :properties do
    @product = Product.find(params[:id])
  end

  member_action :edit_plus do
    @product = Product.find(params[:id])
    register_value :form do
      semantic_form_for(@product) do |f|
        break f
      end
    end
    @content = PanamaCore::Contents.fetch_for(@product.category, :additional_properties_admins)
  end

  member_action :update_plus, :method => :put do
    p = params[:product]
    @product = Product.find(params[:id])
    category_id = p[:category_id]
    @product.category_id = category_id unless category_id.nil?
    @product.attach_properties!
    if @product.update_attributes(p.merge(dispose_options(p)))
      redirect_to system_product_path(@product)
    end
  end

  member_action :attach_properties, :method => :put do
    @product = Product.find(params[:id])
    @product.attach_properties!
    redirect_to system_product_path(params[:id])
  end

  action_item :only => :show do
    link_to('Attach Properties', attach_properties_system_product_path(params[:id]), :method => :put) +
    link_to('编辑 Properties', edit_plus_system_product_path(params[:id]))
  end

  def form_builder(product)

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
    @content = PanamaCore::Contents.fetch_for(@category, :additional_properties_admins)

    if @content.nil?
      render :text => '<h1>No having property!</h1>'
    else
      render_content(@content, locals: { category: @category })
    end
  end



  def additional_properties_content(category = nil)
    @content = PanamaCore::Contents.fetch_for(category, :additional_properties)
  end
end