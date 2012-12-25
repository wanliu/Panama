class Admins::Shops::CategoriesController < Admins::Shops::SectionController

  has_widgets do |root|
    root << widget(:table, :source => @children)
  end

  def index
    @category = current_shop.category
    @children = @category.children
  end
end
