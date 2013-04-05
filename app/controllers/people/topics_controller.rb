#encoding: utf-8
class People::TopicsController < People::BaseController
  before_filter :login_required

  def create
    opts = max_level(params[:topic].delete(:friends))
    if opts[:circles].length <= 0
      respond_format({message: "没有选择范围!"}, 403)
      return
    end
    @topic = current_user.topics.create(params[:topic].merge({
        status: opts[:status],
        user_id: current_user.id
      }))
    if @topic.valid?
      opts[:circles].each do |circle|
        @topic.receives.create(receive: circle)
      end
      respond_format(@topic.as_json(:include => :owner))
    else
      respond_format(draw_errors_message(@topic), 403)
    end
  end

  def index
    @topics = Topic.find_user_or_friends(current_user.id, :all)
    .order("created_at desc")
    respond_to do |format|
      format.json{ render json: @topics.as_json(:include => :owner) }
    end
  end

  def receives
    @topic = current_user.topics.find(params[:id])
    respond_to do |format|
      format.json{ render json: @topic.receive_users }
    end
  end

  private
  def respond_format(json, status = 200)
    respond_to do |format|
      format.json{ render json: json, status: status }
    end
  end

  def max_level(friends)
    data = {}
    if Topic.is_level(friends, "puliceity")
      return {status: :puliceity, circles: [current_user]}
    elsif Topic.is_level(friends, "external")
      circles = current_user.circles + current_user.all_friend_circles
      data = {status: :external, circles: circles}
    elsif Topic.is_level(friends, "circle")
      data = {status: :circle, circles: current_user.circles}
    else
      data = Topic.receive_other(friends)
    end
    params[:topic].delete(:topic_category_id)
    data
  end
end