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
  end

  def create            
    @product = current_shop.products.create(params[:product].merge!(convent_attachment_params))

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
  
  private 

  def convent_attachment_params
    options = {:attachments => [], :default_attachment => nil }
    params.delete(:attachment).each do |k ,v |
      attachment = Attachment.where(:id => v).first
      options[:attachments] << attachment
      options[:default_attachment] = attachment if k == "default"      
    end
    options
  end
end
