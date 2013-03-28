class Admins::Shops::CommunitiesController < Admins::Shops::SectionController
  def index
    @circles = current_shop.circles
    user_ids = @circles.map{|c| c.friends.map{|f| f.user_id} }.flatten
    @topics = current_shop.all_topics(user_ids)
  end
end