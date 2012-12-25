class Admins::Shops::ProductsController < Admins::Shops::SectionController
  has_widgets do |root|
    root << widget(:table, :source => @products)
  end

  def index
    @products = []
  end
end
