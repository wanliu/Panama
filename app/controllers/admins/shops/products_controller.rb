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
    @product = Product.new
    # @colors = [ ['#FFB6C1', '浅粉红'], ['#FFC0CB', '粉红'],
    #             ['#7B68EE', '中板岩蓝'], ['#00FA9A', '中春绿'],
    #             ['#DAA520', '金菊黄'], ['#1E90FF', '道奇蓝'],
    #             ['#5F9EA0', '军兰'], ['#40E0D0', '绿宝石']]
    @colours = [ {id: 1, rgb: '#FFB6C1', name: '浅粉红'}, {id: 2, rgb: '#FFC0CB', name: '粉红'},
                {id: 3, rgb: '#7B68EE', name: '中板岩蓝'}, {id: 4, rgb: '#00FA9A', name: '中春绿'}]
    @sizes = ['M', 'ML', 'L', 'XL', 'XXL', 'XXL', '均码']
  end

  def create
    @product = current_shop.products.create params[:product]
    if @product.valid?
      render :action => :show
    else
      render :action => :edit
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    @product.update_attributes(params[:product])
    if @product.valid?
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

  def colors
  end

  def sizes
  end
end
