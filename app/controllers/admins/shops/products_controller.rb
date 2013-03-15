#encoding: utf-8
require 'orm_fs'

class Admins::Shops::ProductsController < Admins::Shops::SectionController

  helper_method :value_for
  before_filter :content_product_form, :except => [:new, :create, :index, :additional_properties, :products_by_category]

  ajaxify_pages :new, :edit, :create, :index, :show, :update

  has_widgets do |root|
    root << widget(:table, :source => @products)
  end

  def index
    node = current_shop.shops_category

    @categories = ShopsCategory.sort_by_ancestry(node.descendants)
    @products = current_shop.products
  end

  def new
    #模拟数据库对象的属性操作
    # Hash.class_eval do
    #   ['name', 'colours', 'sizes', 'items', :title, :value, :id, :checked].each do |method|
    #     define_method method do
    #       self[method]
    #     end
    #   end
    # end

    @product = Product.new
    form_builder(@product)
    @category_root = Category.root
    @shops_category_root = current_shop.shops_category
    @content = additional_properties_content
    @category = @product.build_category(:name => 'No Selected')
    #模拟数据库对象
    # def @product.styles
    #   [
    #     {'name' => 'colours', 'items' =>
    #       [ {value: '#FFB6C1', title: '浅粉红'}, {value: '#FFC0CB', title: '粉红'},
    #         {value: '#7B68EE', title: '中板岩蓝'}, {value: '#00FA9A', title: '中春绿'}
    #       ]
    #     },
    #     {'name' => 'sizes', 'items' =>
    #       [ {title: 'M', value: 'M'}, {title: 'ML', value: 'ML'}, {title: 'L', value: 'L'},
    #         {title: 'XL', value: 'XL'}, {title: 'XXL', value: 'XXL'}, {title: 'XXXL', value: 'XXXL'}
    #       ]
    #     }
    #   ]
    # end

  end

  def create
    @product = current_shop.products.build(params[:product].merge(dispose_options))
    @product.attach_properties!
    @product.properties.each do |property|
      property_name = property.name.to_sym
      @product.send("#{property_name}=", params[:product][property_name])
      # @product.write_property(name, params[:product][property_name])
    end
    @category = @product.category
    @content = additional_properties_content(@category)

    if @product.save
      @product.create_style_subs(params)
      render :action => :show
    else
      @temp_subs = @product.subs_editing(params)
      @temp_styles = @product.sytles_editing(params)
      render :action => :edit
    end
  end

  def edit
    @product = Product.find(params[:id])
    @category_root = Category.root
    @category = @product.category || @product.build_category(:name => 'No Selected')
    @shops_category_root = current_shop.shops_category
    @content = additional_properties_content(@category)
  end

  def update
    @product = Product.find(params[:id])
    @product.update_attributes(params[:product].merge(dispose_options))
    @shops_category_root = current_shop.shops_category
    @category = @product.category
    @content = additional_properties_content(@category)

    if @product.valid?
      @product.update_style_subs(params)
      render :action => :show
    else
      render :action => :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    render :text => :ok
  end

  def show
    @product = Product.find(params[:id])
  end

  def accept_product
    @product = Product.find(params[:product_id])
    @shops_category = ShopsCategory.find(params[:shops_category_id])
    @product.shops_category = @shops_category
    if @product.save
      render :text => :ok
    else
      render :text => :error
    end
  end

  def additional_properties
    root = '/panama'.to_dir
    # @product = Product.find(params[:id])
    @product = params[:product_id].blank? ? Product.new : Product.find(params[:product_id])
    form_builder @product
    @category = Category.find(params[:category_id])
    @product.category = @category
    @product.attach_properties!

    @content = additional_properties_content(@category)

    if @content.nil?
      render :text => :ok
    else
      render_content_ex(@content, locals: { category: @category })
    end
  end

  def products_by_category
    category = ShopsCategory.find(params[:shops_category_id])
    @products = category.products

    render :partial => "products_table", :locals => { :products => @products }
  end

  def category_page
    render :layout => false
  end

  private

  def dispose_options
    args = { :attachment_ids => [] }
    attachments = params[:product].fetch(:attachment_ids, {})
    attachments.each do | k, v |
      args[:attachment_ids] << v
    end
    args
  end

  def additional_properties_content(category = nil)
    if category.nil?
      Content.lookup_name(:default_category).first
    else
      @content = Content.fetch_for(@category, :additional_properties, :autocreate => false)
      @content ||= Content.lookup_name(:default_category).first
    end
  end

  def form_builder(product)
    register_value :form do
      simple_form_for(product) do |f|
        break f
      end
    end
  end

  def content_product_form
    @product = Product.find(params[:id] || params[:product_id])
    form_builder @product
  end
end
