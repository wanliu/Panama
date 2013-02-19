#encoding: utf-8
class Admins::Shops::ProductsController < Admins::Shops::SectionController

  ajaxify_pages :new, :edit, :create, :index, :show, :update

  has_widgets do |root|
    root << widget(:table, :source => @products)
  end


  def index    
    node = current_shop.category
    @categories = node.traverse(:depth_first)
    @categories.shift
    @products = current_shop.products
  end

  def new
    #模拟数据库对象的属性操作
    Hash.class_eval do
      ['name', 'colours', 'sizes', 'items', :title, :value, :id, :checked].each do |method|
        define_method method do
          self[method]
        end
      end
    end

    @product = Product.new
    #@category_root = Category.find_by(:name => "liulei shop_root")
    # @category_root = current_shop.category

    #模拟数据库对象
    def @product.styles
      [
        {'name' => 'colours', 'items' =>
          [ {value: '#FFB6C1', title: '浅粉红'}, {value: '#FFC0CB', title: '粉红'},
            {value: '#7B68EE', title: '中板岩蓝'}, {value: '#00FA9A', title: '中春绿'}
          ]
        },
        {'name' => 'sizes', 'items' =>
          [ {title: 'M', value: 'M'}, {title: 'ML', value: 'ML'}, {title: 'L', value: 'L'},
            {title: 'XL', value: 'XL'}, {title: 'XXL', value: 'XL'}, {title: 'XXXL', value: 'XL'}
          ]
        }
      ]
    end

  end

  def create
    @product = current_shop.products.create(params[:product].merge(dispose_options))

    if @product.valid?
      create_style_and_subs
      render :action => :show
    else
      @temp_subs = subs_back_for_edit
      @temp_styles = sytles_back_for_edit
      render :action => :edit
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    @product.update_attributes(params[:product].merge(dispose_options))

    if @product.valid?
      updata_style_and_subs
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
    @category = Category.find(params[:category_id])
    @product.category = @category
    if @product.save
      render :text => :ok
    else
      render :text => :error
    end
  end  

  def products_by_category
    category = Category.find(params[:category_id])
    @products = category.products
    render :partial => "products_table", :locals => { :products => @products }
  end

  private

  def create_style_and_subs
    yield if block_given?

    params[:sub_products].values.each do |sub|
      @product.sub_products.create!(sub)
    end unless params[:sub_products].blank?

    params[:style].each_pair do |name, value|
      one_group = @product.styles.create!(:name => name)
      value.values.each do |item|
        item = item.clone
        item[:checked] = !item[:checked].blank?
        one_group.items.create!(item)
      end
    end unless params[:style].blank?
  end

  def updata_style_and_subs
    create_style_and_subs do
      @product.sub_products.clear
      @product.styles.clear
    end
  end

  def subs_back_for_edit
    params[:sub_products]
  end

  def sytles_back_for_edit
    result = []
    params[:style].each_pair do |name, items|
      result.push('name' => name, 'items' => items.values)
    end unless params[:style].blank?
    result
  end

  def dispose_options
    args = { :attachment_ids => [] }    
    params[:product][:attachment_ids].each do | k, v |
      args[:attachment_ids] << v
    end unless params[:product][:attachment_ids].blank?
    args
  end     
end