#encoding: utf-8
class People::TopicsController < People::BaseController
  before_filter :login_and_service_required

  def create
    ptopic = params[:topic]
    opts = max_level(ptopic.delete(:friends))
    ptopic.delete(:topic_category_id) unless opts[:status] == :community
    atta_opts = ptopic.delete(:attachments) || {}

    if opts[:circles].length <= 0
      respond_format({message: "没有选择范围!"}, 403)
      return
    end
    @topic = current_user.topics.create(ptopic.merge({
        status: opts[:status],
        user_id: current_user.id
      }))
    if @topic.valid?
      @topic.receives.creates(opts[:circles])
      @topic.attachments.creates(atta_opts.values)
      respond_format(@topic.as_json(:include => :owner))
    else
      respond_format(draw_errors_message(@topic), 403)
    end
  end

  def index
    circle_id = params[:circle_id]
    _topics = circle_id == "community" ?  topic_following : circles(circle_id)
    @topics = _topics.order("created_at desc").limit(30)

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

  def following
    @circles = current_user.circles
    respond_to do |format|
      format.html
    end
  end

  private
  def topic_following
    current_user.following_shop_topics
  end

  def circles(circle_id)
    @circles = circle_id == "all" ? :all : Circle.where(id: circle_id)
    Topic.find_user_or_friends(current_user, @circles)
  end

  def respond_format(json, status = 200)
    respond_to do |format|
      format.json{ render json: json, status: status }
    end
  end

  def max_level(friends)
    if Topic.is_level(friends, "puliceity")
      return {status: :puliceity, circles: [current_user]}
    elsif Topic.is_level(friends, "external")
      circles = current_user.circles + current_user.all_friend_circles
      return {status: :external, circles: circles}
    elsif Topic.is_level(friends, "circle")
      receive = Topic.receive_other(friends)
      receive[:circles] = current_user.circles + receive[:circles]
      return receive
    else
      return Topic.receive_other(friends)
    end
  end
end