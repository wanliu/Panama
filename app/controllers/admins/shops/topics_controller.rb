#encoding: utf-8
class Admins::Shops::TopicsController < Admins::Shops::SectionController

  def create
    receive_user_ids, status = max_level

    @topic = current_shop.topics.create(
      status: status, content: params[:content], user_id: current_user.id)
    respond_to do |format|
      if @topic.valid?
        receive_user_ids.uniq.each do |user_id|
          @topic.receives.user(user_id)
        end
        format.json{ render json: format_json(@topic) }
      else
        format.json{ render json: draw_errors_message(@topic), status: 403 }
      end
    end
  end

  def index
    @topics = current_shop.all_topics(@circle.friends.map{|f| f.user_id}).order("created_at desc")
  end

  private
  def format_json(topic)
    _topic = topic.as_json
    _topic[:status] = topic.status.name
    _topic[:avatar_url] = topic.user.icon
    _topic[:login] = topic.user.login
    _topic
  end

  def max_level
    if params[:friends].include?("puliceity")
      user_ids = current_shop.all_friends.select(:user_id).map{|f| f.user_id}
      return [user_ids, :puliceity]
    elsif params[:friends].include?("external")
      uids = current_shop.all_friends.select(:user_id).map{|f| f.user_id}
      user_ids = current_shop.all_friend_circles.select("distinct user_id").map{|f| f.user_id}
      return [user_ids + uids, :external]
    elsif params[:friends].include?("circle")
      user_ids = current_shop.all_friends.select(:user_id).map{|f| f.user_id}
      return [user_ids, :circle]
    else
      user_ids = current_shop.find_friend_by_circle(params[:friends]).
      select("distinct user_id").map{|f| f.user_id}
      return [user_ids, :circle]
    end
  end
end