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
    Hash.class_eval do
      def id
        self[:id]
      end
      def name
        self[:name]
      end
      def rgb
        self[:rgb]
      end
    end
    @product = Product.new
    @colours = [ {id: 1, rgb: '#FFB6C1', name: '浅粉红'}, {id: 2, rgb: '#FFC0CB', name: '粉红'},
                {id: 3, rgb: '#7B68EE', name: '中板岩蓝'}, {id: 4, rgb: '#00FA9A', name: '中春绿'}]
    @sizes = ['M', 'ML', 'L', 'XL', 'XXL', 'XXXL']
  end

  def create
    @product = current_shop.products.create params[:product]
    @colours = [ {id: 1, rgb: '#FFB6C1', name: '浅粉红'}, {id: 2, rgb: '#FFC0CB', name: '粉红'},
                {id: 3, rgb: '#7B68EE', name: '中板岩蓝'}, {id: 4, rgb: '#00FA9A', name: '中春绿'}]
    @sizes = ['M', 'ML', 'L', 'XL', 'XXL', 'XXXL']

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

  # class << self
  #   attr_accessor :colours, :sizes
  # end
end
