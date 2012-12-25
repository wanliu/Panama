class Admins::Shops::PendingController < Admins::Shops::SectionController
  has_widgets do |root|
    root << widget(:table, :source => @orders)
  end

  def index
    @orders = []
  end
end
