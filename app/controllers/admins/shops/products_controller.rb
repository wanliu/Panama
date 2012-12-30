class Admins::Shops::ProductsController < Admins::Shops::SectionController
  has_widgets do |root|
    root << widget(:table, :source => @products)
  end

  def new
    @product = Product.new
  end

  def index
    node = current_shop.category
    @categories = node.traverse(:depth_first)
    @categories.shift
    @products = []
  end
end
