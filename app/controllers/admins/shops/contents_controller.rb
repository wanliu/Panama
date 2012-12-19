class Admins::Shops::ContentsController < Admins::Shops::SectionController

  has_widgets do |root|
    root << widget(:search)
    root << widget(:button, :new_content)
    root << widget(:table, :source => @contents)
  end

  def index
    @contents = current_shop.contents
  end
end