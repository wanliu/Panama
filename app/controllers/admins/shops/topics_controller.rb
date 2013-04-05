#encoding: utf-8
class Admins::Shops::TopicsController < Admins::Shops::SectionController

  def create
    opts = max_level(params[:topic].delete(:friends))
    if opts[:circles].length <= 0
      respond_format({message: "没有选择范围!"}, 403)
      return
    end
    @topic = current_shop.topics.create(params[:topic].merge({
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
    _topics = params[:circles]=="puliceity" ? receive_topic : circle_topics
    @topics = _topics.limit(30).order("created_at desc")
    respond_to do |format|
      format.json{ render json: @topics.as_json(:include => :owner) }
      format.html
    end
  end

  def my_related
    @circles = current_shop.circles
    @followers = current_shop.followers
    @categories = current_shop.topic_categories
    respond_to do |format|
      format.html
      format.json{ render json: @topics }
    end
  end

  def category
    @topics = current_shop.topics.where(topic_category_id: params[:topic_category_id])
    respond_to do |format|
      format.json{ render json: @topics }
      format.html
    end
  end

  def receives
    @topic = current_shop.topics.find(params[:id])
    respond_to do |format|
      format.json{ render json: @topic.receive_users }
      format.html
    end
  end

  private
  def receive_topic
    current_shop.topic_receives.joins(:topic)
  end

  def circle_topics
    if params[:circle_id] == "all"
      @circles = :all
    elsif not params[:circle_id].blank?
      @circles = current_shop.circles.where(:id => params[:circle_id])
    end
    current_shop.all_circle_topics(@circles)
  end

  def respond_format(json, status = 200)
    respond_to do |format|
      format.json{ render json: json, status: status }
    end
  end

  def max_level(friends)
    data = {}
    if Topic.is_level(friends, "puliceity")
      return {status: :puliceity, circles: [current_shop]}
    elsif Topic.is_level(friends, "external")
      circles = current_shop.circles + current_shop.all_friend_circles
      data = {status: :external, circles: circles}
    elsif Topic.is_level(friends, "circle")
      data = {status: :circle, circles: current_shop.circles}
    else
      data = Topic.receive_other(friends)
    end
    params[:topic].delete(:topic_category_id)
    data
  end

end