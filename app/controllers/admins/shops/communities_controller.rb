class Admins::Shops::CommunitiesController < Admins::Shops::SectionController
  def index
    @circles = current_shop.circles
  end
end