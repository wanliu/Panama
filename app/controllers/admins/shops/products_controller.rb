class Admins::Shops::ProductsController < Admins::Shops::SectionController

  ajaxify_pages :new, :edit, :create, :index, :show, :update

  has_widgets do |root|
    root << widget(:table, :source => @products)
  end


  def index    
    node = current_shop.category

    @categories = Category.sort_by_ancestry(node.descendants)
    @products = current_shop.products
  end

  def new
    @product = Product.new
    @category_root = current_shop.category
  end

  def create
    debugger
    @product = current_shop.products.create(params[:product].merge(dispose_options))

    if @product.valid?
      render :action => :show
    else
      render :action => :edit
    end
  end

  def edit
    @product = Product.find(params[:id])
    @category_root = current_shop.category
  end

  def update
    @product = Product.find(params[:id])
    @product.update_attributes(params[:product].merge(dispose_options))
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
  
  private
  def dispose_options
    args = { :attachment_ids => [] }    
    attachments = params[:product].fetch(:attachment_ids, {})
    attachments.each do | k, v |
      args[:attachment_ids] << v
    end
    args
  end     
end
